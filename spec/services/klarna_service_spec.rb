require 'rails_helper'

describe KlarnaService do
  let(:urls) do
    { checkout: "https://36a1fe86a965.ngrok.io/anvandare/1/betalning/#{Payment::PAYMENT_TYPE_MEMBER}",
      confirmation: "https://36a1fe86a965.ngrok.io/anvandare/1/betalning/'{checkout.order.id}'",
      push: "https://36a1fe86a965.ngrok.io/anvandare/betalning/klarna_push?id=1&klarna_id='{checkout.order.id}'"
    }
  end

  let(:valid_payment_data) do
    { id: '1',
      user_id: '1',
      type: Payment::PAYMENT_TYPE_MEMBER,
      currency: 'SEK',
      item_price: SHF_MEMBER_FEE,
      paid_item: paid_item = I18n.t('payment.payment_type.member_fee'),
      urls:  urls }
  end

  let(:invalid_payment_type) do
    payment_data = { type: 'invalid' }
    described_class.create_order(payment_data)
  end

  let(:valid_order) do
    described_class.create_order(valid_payment_data)
  end

  let(:invalid_password) do
    KLARNA_API_AUTH_PASSWORD = 'wrong_password'
  end

  let(:fetched_order) do
    described_class.get_order(valid_order['id'])
  end

  describe '.create_order', vcr: { record: :once } do
    # Klarna "Checkout" API

    it 'raises exception if invalid payment_type' do
      expect { invalid_payment_type }.to raise_exception RuntimeError
    end

    it 'returns parsed response if successful' do
      expect(valid_order).to be_instance_of(Hash)
      expect(valid_order['merchant_reference1']).to eq '1' # user ID
      expect(valid_order['merchant_reference2']).to eq '1' # SHF Payment ID
      expect(valid_order['status']).to eq 'checkout_incomplete'
      expect(valid_order['order_amount']).to eq SHF_MEMBER_FEE
    end

    it 'raises exception if authorization fails' do
      invalid_password
      expect { valid_order }.to raise_exception(RuntimeError,
                                                'HTTP Status: 401, Unauthorized')
    end
  end

  describe '.get_checkout_order', vcr: { record: :once } do
    # Klarna "Checkout" API

    it 'returns parsed response if successful' do
      valid_order
      klarna_order = KlarnaService.get_checkout_order(valid_order['order_id'])

      expect(klarna_order['order_id']).to eq valid_order['order_id']
      expect(klarna_order['status']).to eq 'checkout_incomplete'
      expect(klarna_order['customer']['type']).to eq 'person'
      expect(klarna_order['order_amount']).to eq SHF_MEMBER_FEE
    end

    it 'raises exception if authorization fails' do
      valid_order
      invalid_password

      expect { KlarnaService.get_checkout_order(valid_order['order_id']) }
                .to raise_exception(RuntimeError, 'HTTP Status: 401, Unauthorized')
    end
  end




  describe '.get_order', :vcr do
    # Klarna "Order Management" API

    it 'returns parsed response if successful' do
      expect(fetched_order).to be_instance_of(Hash)
      expect(fetched_order['id']).to eq valid_order['id']
      expect(fetched_order['merchant_reference']['order_id']).to eq '1'
    end

    it 'raises exception if unsuccessful' do
      invalid_key
      expect { fetched_order }.to raise_exception(RuntimeError,
                                                  'HTTP Status: 401, Unauthorized')
    end
  end

  describe '.validate_webhook_origin' do
    it 'returns resource data for valid json_web_token' do
      expect(valid_jwt_payload).to be_instance_of(Hash)
    end

    it 'raises exception if not expected issuer' do
      allow(JWT).to receive(:decode).and_return(token_bad_issuer)
      expect { described_class.validate_webhook_origin('123') }
        .to raise_exception(RuntimeError, 'JWT issuer not HIPS')
    end

    it 'raises exception if not expected algorithm' do
      allow(JWT).to receive(:decode).and_return(token_bad_algo)
      expect { described_class.validate_webhook_origin('123') }
        .to raise_exception(RuntimeError, 'JWT wrong algorithm')
    end
  end
end
