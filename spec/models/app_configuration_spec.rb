require 'rails_helper'

RSpec.describe AdminOnly::AppConfiguration, type: :model do
  let(:app_configuration) { create(:app_configuration) }

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:app_configuration)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :chair_signature_file_name }
    it { is_expected.to have_db_column :chair_signature_content_type }
    it { is_expected.to have_db_column :chair_signature_file_size }
    it { is_expected.to have_db_column :chair_signature_updated_at }
    it { is_expected.to have_db_column :shf_logo_file_name }
    it { is_expected.to have_db_column :shf_logo_content_type }
    it { is_expected.to have_db_column :shf_logo_file_size }
    it { is_expected.to have_db_column :shf_logo_updated_at }
  end

  describe 'Validations' do
    it do
      is_expected.to validate_attachment_content_type(:chair_signature)
        .allowing('image/png', 'image/jpeg')
        .rejecting('image/gif', 'image/bmp')
    end
    it do
      is_expected.to validate_attachment_content_type(:shf_logo)
        .allowing('image/png', 'image/jpeg')
        .rejecting('image/gif', 'image/bmp')
    end

    describe 'validates file contents and file type - chairperson signature' do
      let(:file_root) { "#{Rails.root}/spec/fixtures/member_photos/" }
      let(:txt_file)  { File.new(file_root + 'text_file.jpg') }
      let(:gif_file)  { File.new(file_root + 'gif_file.jpg') }
      let(:ico_file)  { File.new(file_root + 'ico_file.png') }
      let(:xyz_file)  { File.new(file_root + 'member_with_dog.xyz') }

      it 'rejects if content not jpeg or png' do
        app_configuration.chair_signature = txt_file
        expect(app_configuration).not_to be_valid

        app_configuration.chair_signature = gif_file
        expect(app_configuration).not_to be_valid

        app_configuration.chair_signature = ico_file
        expect(app_configuration).not_to be_valid
      end
      it 'rejects if content OK but file type wrong' do
        app_configuration.chair_signature = xyz_file
        expect(app_configuration).not_to be_valid
      end
    end

    describe 'validates file contents and file type - SHF logo' do
      let(:file_root) { "#{Rails.root}/spec/fixtures/member_photos/" }
      let(:txt_file)  { File.new(file_root + 'text_file.jpg') }
      let(:gif_file)  { File.new(file_root + 'gif_file.jpg') }
      let(:ico_file)  { File.new(file_root + 'ico_file.png') }
      let(:xyz_file)  { File.new(file_root + 'member_with_dog.xyz') }

      it 'rejects if content not jpeg or png' do
        app_configuration.shf_logo = txt_file
        expect(app_configuration).not_to be_valid

        app_configuration.shf_logo = gif_file
        expect(app_configuration).not_to be_valid

        app_configuration.shf_logo = ico_file
        expect(app_configuration).not_to be_valid
      end
      it 'rejects if content OK but file type wrong' do
        app_configuration.shf_logo = xyz_file
        expect(app_configuration).not_to be_valid
      end
    end
  end


end