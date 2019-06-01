require 'rails_helper'

require_relative File.join(Rails.root, 'features', 'support', 'step_errors')


RSpec.describe 'Cucumber Steps Errors' do

  describe 'SHFStepsError' do

    let(:error_class) { SHFStepsError }

    it 'will show the message if a previous error raised' do

      begin
        raise NoMethodError
      rescue NoMethodError
        begin
          raise SHFStepsError
        rescue SHFStepsError => shf_error
        end
      end

      expect(shf_error.message).to eq "SHFStepsError: This was raised after this error: NoMethodError."
    end


    it 'shows just the class name if no previous error was raised' do

      begin
        raise error_class
      rescue NoMethodError, error_class
        shf_error = error_class.new
      end

      expect(shf_error.message).to eq "SHFStepsError"
    end

    it 'shows just the class name if it was the most recent error raised' do
      begin
        raise error_class
      rescue error_class => shf_error
      end
      expect(shf_error.message).to eq "SHFStepsError"
    end
  end


  describe 'PagenameUnknown' do

    it 'default message is PagenameUnknown with a reminder to add it to the known pages ' do
      expect(PagenameUnknown.new.message).to eq "PagenameUnknown: The page name is unknown.\n  You may need to add it to the list of known paths in the get_path() case statement."
    end

    it 'message with the page name' do
      expect(PagenameUnknown.new(page_name: 'blorfo').message).to eq "PagenameUnknown: The page name 'blorfo' is unknown.\n  You may need to add it to the list of known paths in the get_path() case statement."
    end


    describe 'wrapped (nested) error' do

      it 'raise and show original error' do

        begin
          raise NoMethodError
        rescue NoMethodError
          begin
            raise PagenameUnknown.new(page_name: 'blorfo')
          rescue PagenameUnknown => shf_error
          end
        end

        expect(shf_error.message).to eq "PagenameUnknown: This was raised after this error: NoMethodError.: The page name 'blorfo' is unknown.\n  You may need to add it to the list of known paths in the get_path() case statement."
      end
    end

  end


  describe 'UnableToVisitConstructedPath' do

    it 'default message is UnableToVisitConstructedPath with a reminder to maybe add it to the list of known pages/paths' do
      expect(UnableToVisitConstructedPath.new.message).to eq "UnableToVisitConstructedPath: Unable to visit the manually constructed path.\n  You may need to add it to the list of known paths in the get_path() case statement."
    end

    it 'message with the constructed path' do
      expect(UnableToVisitConstructedPath.new(constructed_path: 'something_blorfo_page').message).to eq "UnableToVisitConstructedPath: Unable to visit the manually constructed path 'something_blorfo_page'.\n  You may need to add it to the list of known paths in the get_path() case statement."
    end


    describe 'wrapped (nested) error' do

      it 'raise and show original error' do

        begin
          raise NoMethodError
        rescue NoMethodError
          begin
            raise UnableToVisitConstructedPath.new(constructed_path: 'some_constructed_path')
          rescue => shf_error
          end
        end

        expect(shf_error.message).to eq "UnableToVisitConstructedPath: This was raised after this error: NoMethodError.: Unable to visit the manually constructed path 'some_constructed_path'.\n  You may need to add it to the list of known paths in the get_path() case statement."
      end
    end
  end

end
