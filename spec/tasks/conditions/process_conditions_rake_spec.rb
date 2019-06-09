require 'rails_helper'
require 'shared_context/rake'
require 'shared_context/activity_logger'

RSpec.describe 'conditions/process_conditions shf:process_conditions', type: :task do

  include_context 'rake'

  EXPECTED_PROCESSING_EXCEPTION_LOG_ENTRY = 'Exception: uninitialized constant ' +
                                            'AnInvalidClass:  #<NameError: ' +
                                            'uninitialized constant AnInvalidClass>'

  EXPECTED_SLACK_EXCEPTION_LOG_ENTRIES =
      [
        'Slack::Notifier::APIError Exception:',
        'Slack Notifications turned off! Condition processing continuing without it.',
        'Retrying the previous condition...'
      ]

  let(:filepath) { LogfileNamer.name_for(Condition) }

  before(:each) do
    File.delete(filepath) if File.file?(filepath)
  end

  let(:valid_conditions) do
    [{ class_name: 'HBrandingFeeDueAlert',
       timing:     :after,
       config:     { days: [2, 9, 14, 30, 60] } },
     { class_name: 'HBrandingFeeWillExpireAlert',
        timing:     :before,
        config:     { days: [2, 9, 14, 30, 60] } }
    ]
  end

  let(:invalid_condition) do
    [{ class_name: 'AnInvalidClass', # must sort _before_ other (valid) condition class names
       timing:     :after,
       config:     { days: [2, 9, 14, 30, 60] } },
    ]
  end

  describe 'normal processing' do

    before(:each) { Condition.create!(valid_conditions) }

    it 'logs all conditions processed and indicates no errors' do
      output_loaded_condition_info

      # stub out the Slack notification methods
      allow(SHFNotifySlack).to receive(:notification)
                                   .and_return(true)

      # should never create a SlackNotifier during this test
      expect(Slack::Notifier).not_to receive(:new)

      # precondition: log file should not exist
      expect(File.exist?(filepath)).to be false

      expect { subject.invoke }.not_to raise_error

      # post-conditions:
      # 1) Log file indicates all conditions were processed successfully
      valid_conditions.each do |condition|
        expect(File.read(filepath)).to include("[info] #{condition[:class_name]}")
      end

      # 1) Log file does not contain error message(s)
      expect(File.read(filepath)).not_to include('[error]')
    end
  end

  describe 'exception handling' do

    before(:each) { Condition.create!(valid_conditions) }

    describe 'Slack Notification failure' do

      it 'logs the notification error but keeps processing all conditions' do

        output_loaded_condition_info

        # Slack notification error will be raised:
        allow(SHFNotifySlack).to receive(:notification)
                                     .and_raise(Slack::Notifier::APIError)

        # should never create a SlackNotifier during this test
        expect(Slack::Notifier).not_to receive(:new)

        # precondition: log file should not exist
        expect(File.exist?(filepath)).to be false

        # the error will not percolate up and be raised; processing continues
        expect { subject.invoke }.not_to raise_error

        # post-conditions:
        # 1) log should have the Slack Notification Exception info
        EXPECTED_SLACK_EXCEPTION_LOG_ENTRIES.each do |msg|
          expect(File.read(filepath)).to include msg
        end

        # 2) All conditions were processed successfully
        valid_conditions.each do |condition|
          expect(File.read(filepath)).to include("[info] #{condition[:class_name]}")
        end
      end

    end

    describe 'processing failure does not stop other condition processing' do

      it 'logs the processing error and continues with other conditions' do

        Condition.create!(invalid_condition)
        output_loaded_condition_info

        # stub out the Slack notification methods
        allow(SHFNotifySlack).to receive(:notification)
                                     .and_return(true)

        # should never create a SlackNotifier during this test
        expect(Slack::Notifier).not_to receive(:new)

        # precondition: log file should not exist
        expect(File.exist?(filepath)).to be false

        expect { subject.invoke }.not_to raise_error

        # post-conditions:
        # 1) Log should have the processing Exception info
        expect(File.read(filepath))
            .to include EXPECTED_PROCESSING_EXCEPTION_LOG_ENTRY

        # 2) Log file indicates other conditions were processed successfully
        valid_conditions.each do |condition|
          expect(File.read(filepath)).to include("[info] #{condition[:class_name]}")
        end
      end

    end

    describe 'processing AND slack notification failures does not stop condition processing' do

      it 'retries condition after Slack error, logs condition error and continues with remaining conditions' do

        Condition.create!(invalid_condition)
        output_loaded_condition_info

        # Slack notification error that will be raised:
        allow(SHFNotifySlack).to receive(:notification)
                             .and_raise(Slack::Notifier::APIError)

        # should never create a SlackNotifier during this test
        expect(Slack::Notifier).not_to receive(:new)

        # precondition: log file should not exist
        expect(File.exist?(filepath)).to be false

        expect { subject.invoke }.not_to raise_error

        # post-conditions:
        # 1) Log should have the processing Exception info
        expect(File.read(filepath))
            .to include EXPECTED_PROCESSING_EXCEPTION_LOG_ENTRY

        # 2) Log should have the Slack Notification Exception info
        EXPECTED_SLACK_EXCEPTION_LOG_ENTRIES.each do |msg|
          expect(File.read(filepath)).to include msg
        end

        # 3) Log file indicates other conditions were processed successfully
        valid_conditions.each do |condition|
          expect(File.read(filepath)).to include("[info] #{condition[:class_name]}")
        end

      end

    end

  end

  def output_loaded_condition_info
    puts "      #{Condition.count} conditions were loaded into the db: #{Condition.order(:class_name).map { |h_cond| h_cond[:class_name] }.join(', ')}"
  end

end
