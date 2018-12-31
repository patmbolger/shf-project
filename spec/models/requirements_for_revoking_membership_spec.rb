require 'rails_helper'

RSpec.describe RequirementsForRevokingMembership, type: :model do

  let(:subject) { RequirementsForRevokingMembership }


  let(:user) { create(:user) }

  let(:member_paid_up) do
    user = build(:member_with_membership_app)
    user.payments << create(:membership_fee_payment)
    user.save!
    user
  end

  let(:member_expired) do
    user = build(:member_with_membership_app)
    user.payments << create(:expired_membership_fee_payment)
    user.save!
    user
  end


  describe '.has_expected_arguments?' do

    it 'args has expected :user key' do
      expect(subject.has_expected_arguments?({ user: 'some user' })).to be_truthy
    end

    it 'args does not have expected :user key' do
      expect(subject.has_expected_arguments?({ not_user: 'not some user' })).to be_falsey
    end

    it 'args is nil' do
      expect(subject.has_expected_arguments?(nil)).to be_falsey
    end
  end


  describe '.requirements_met?' do

    it 'user.member? == true and payment NOT expired' do
      expect(subject.requirements_met?({user: member_paid_up})).to be_falsey
    end

    it 'user.member? == false' do
      expect(subject.requirements_met?({user: user})).to be_falsey
    end

    it 'user.member == true but payment has expired' do
      expect(subject.requirements_met?({user: member_expired})).to be_truthy
    end

  end


  describe '.satisfied?' do

    it '.has_expected_arguments? is true and requirements_met? is true' do
      expect(subject.satisfied?({ user: member_expired })).to be_truthy
    end

    it '.has_expected_arguments? is true and requirements_met? is false' do
      expect(subject.satisfied?({ user: user })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is true' do
      expect(subject.satisfied?({ not_user: member_paid_up })).to be_falsey
    end

    it '.has_expected_arguments? is false and requirements_met? is false' do
      expect(subject.satisfied?({ not_user: user })).to be_falsey
    end

  end

end
