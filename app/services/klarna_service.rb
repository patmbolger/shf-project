# Interface to Klarna Checkout service API
# https://developers.klarna.com/api/#checkout-api
class KlarnaService
  require 'httparty'

  SUCCESS_CODES = [200, 201, 202].freeze

  def self.create_order(payment_data)

    raise 'Invalid payment type' unless
      payment_data[:type] == Payment::PAYMENT_TYPE_MEMBER ||
      payment_data[:type] == Payment::PAYMENT_TYPE_BRANDING

    item_price = payment_data[:type] == Payment::PAYMENT_TYPE_MEMBER ?
      SHF_MEMBER_FEE : SHF_BRANDING_FEE

    response = HTTParty.post(KLARNA_CHECKOUT_URL,
                             basic_auth: auth,
                             headers: { 'Content-Type' => 'application/json' },
                             body: order_json(payment_data, item_price, urls))

    parsed_response = response.parsed_response

    return parsed_response if SUCCESS_CODES.include?(response.code)

    error = parsed_response['error']

    # Wrap cause exception within HTTP error exception so both appear in log
    begin
      raise "Error: #{error['type']}, #{error['message']}"
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end

  def self.get_order(klarna_id)

    url = KLARNA_ORDER_MGMT_URL + "#{klarna_id}"

    response = HTTParty.get(url,
                  basic_auth: auth,
                  headers: { 'Content-Type' => 'application/json' })

    return response.parsed_response if SUCCESS_CODES.include?(response.code)

    begin
      raise "Error: #{error['type']}, #{error['message']}"
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end

  def self.auth
    { username: KLARNA_MERCHANT_ID, password: KLARNA_SHARED_SECRET }
  end

  private_class_method def self.order_json(user_id, payment_data, item_price, urls)

    if I18n.locale == :en && Rails.env.development?
      locale = 'us-en'
      country = 'US'
    else
      locale = 'sv-se'
      country = 'SE'
    end

    { locale: locale,
      options: {
        color_button: '#003a78',
        color_button_text: '#ffffff',
        color_header: '#232525'
      },
      attachment: {
        content_type: "application/vnd.klarna.internal.emd-v2+json"
      },
      purchase_country: country,
      purchase_currency: payment_data[:currency],
      order_amount: item_price,
      order_tax_amount: 0,
      order_lines: [
        {
          type: 'digital',
          name: payment_data[:paid_item],
          quantity: 1,
          unit_price: item_price,
          tax_rate: 0,
          total_amount: item_price,
          total_tax_amount: 0,
        } ],
      merchant_urls: {
        terms: 'https://hitta.sverigeshundforetagare.se/dokument/innehall/hmarket',
        checkout: urls[:checkout],
        confirmation: urls[:success],
        push: urls[:webhook]
      }
    }.to_json

  end
end
