# Interface to Klarna Checkout service API
# https://developers.klarna.com/api/#checkout-api
class KlarnaService
  require 'httparty'

  SUCCESS_CODES = [200, 201, 202].freeze

  def self.create_order(user_id, session_id, payment_data, urls)

    raise 'Invalid payment type' unless
      payment_data[:type] == Payment::PAYMENT_TYPE_MEMBER ||
      payment_data[:type] == Payment::PAYMENT_TYPE_BRANDING

    item_price = payment_data[:type] == Payment::PAYMENT_TYPE_MEMBER ?
      SHF_MEMBER_FEE : SHF_BRANDING_FEE

    auth = { username: 'PK37529_9397d245f192',
             password: 'oQDZtwYlJIqVRi1R' }

    response = HTTParty.post('https://api.playground.klarna.com/checkout/v3/orders',
                             basic_auth: auth,
                  headers: { 'Content-Type' => 'application/json' },
                  body: order_json(user_id, session_id, payment_data,
                                   item_price, urls))

    parsed_response = response.parsed_response

    debugger

    return parsed_response if SUCCESS_CODES.include?(response.code)

    error = parsed_response['error']

    # Wrap cause exception within HTTP error exception so both appear in log
    begin
      raise "Error: #{error['type']}, #{error['message']}"
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end

  def self.get_order(hips_id)

    url = HIPS_ORDERS_URL + "#{hips_id}"
    response = HTTParty.get(url,
                  headers: { 'Authorization' => "Token token=#{HIPS_PRIVATE_KEY}",
                             'Content-Type' => 'application/json' })

    return response.parsed_response if SUCCESS_CODES.include?(response.code)

    begin
      raise "Error: #{error['type']}, #{error['message']}"
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end

  def self.validate_webhook_origin(jwt)
    token = JWT.decode(jwt, HIPS_RSA_KEY, true, algorithm: JWT_ALGORITHM)

    raise 'JWT issuer not HIPS' unless token[0]['iss'] == JWT_ISSUER

    raise 'JWT wrong algorithm' unless token[1]['alg'] == JWT_ALGORITHM

    token[0]['data']['resource']
  end

  private_class_method def self.order_json(user_id, session_id,
                                           payment_data, item_price, urls)

    { name: 'SHF',
      status: Payment::ORDER_PAYMENT_STATUS[nil],
      locale: 'sv-se',
      customer: {
        type: 'person',
      },
      attachment: {
        body: "customer_account_info: { unique_account_identifier: #{user_id} }",
        content_type: "application/vnd.klarna.internal.emd-v2+json"
      },
      purchase_country: 'SE',
      purchase_currency: 'SEK',
      order_amount: item_price,
      order_tax_amount: 0,
      order_lines: {
        type: 'digital',
        name: payment_data[:paid_item],
        quantity: 1,
        unit_price: item_price,
        tax_rate: 0,
        total_amount: item_price,
        total_tax_amount: 0,
      },
      merchant_urls: {
        terms: 'https://hitta.sverigeshundforetagare.se/dokument/innehall/hmarket',
        checkout: urls[:checkout],
        confirmation: urls[:payment_success],
        push: urls[:webhook]
      }
    }.to_json

  end
end
