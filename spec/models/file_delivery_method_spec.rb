require 'rails_helper'

RSpec.describe AdminOnly::FileDeliveryMethod, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:file_delivery_upload_now)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :description_sv }
    it { is_expected.to have_db_column :description_en }
    it { is_expected.to have_db_column :default_option }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description_sv }
    it { is_expected.to validate_presence_of :description_en }
    it { is_expected.to validate_uniqueness_of :default_option }
    it { is_expected.to validate_uniqueness_of :name }
  end

  describe 'Associations' do
    it { is_expected.to have_many(:shf_applications).dependent(:nullify) }
  end

end
