require 'rails_helper'

RSpec.describe AdminOnly::FileDeliveryMethod, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:file_delivery_method)).to be_valid
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
    it 'should validate that :name is one of defined values' do
      subject { FactoryBot.build(:file_delivery_method)
      is_expected.to validate_inclusion_of(:name)
          .in_array([ AdminOnly::FileDeliveryMethod::METHOD_NAMES.values ]) }
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:shf_applications).dependent(:nullify) }
  end

end
