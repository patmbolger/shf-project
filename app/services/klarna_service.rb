# Interface to Klarna Checkout service API
# https://developers.klarna.com/api/#checkout-api
class KlarnaService
  require 'httparty'

  SUCCESS_CODES = [200, 201, 202, 204].freeze

  def self.create_order(payment_data)

    raise 'Invalid payment type' unless
      payment_data[:type] == Payment::PAYMENT_TYPE_MEMBER ||
      payment_data[:type] == Payment::PAYMENT_TYPE_BRANDING

    response = HTTParty.post(KLARNA_CHECKOUT_URL,
                             basic_auth: auth,
                             headers: { 'Content-Type' => 'application/json' },
                             body: order_json(payment_data))

    parsed_response = response.parsed_response

    return parsed_response if SUCCESS_CODES.include?(response.code)

    # Wrap cause exception within HTTP error exception so both appear in log
    begin
      process_api_error(parsed_response, response.code)
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end

  def self.get_checkout_order(klarna_id)
    # Fetch order using the Checkout API

    url = KLARNA_CHECKOUT_URL + "#{klarna_id}"

    response = HTTParty.get(url,
                            basic_auth: auth,
                            headers: { 'Content-Type' => 'application/json' })

    parsed_response = response.parsed_response

    return parsed_response if SUCCESS_CODES.include?(response.code)

    error = parsed_response['error']

    begin
      process_api_error(parsed_response, response.code)
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end

  def self.get_order(klarna_id)
    # Fetch order using the Order Management API

    url = KLARNA_ORDER_MGMT_URL + "#{klarna_id}"

    response = HTTParty.get(url,
                            basic_auth: auth,
                            headers: { 'Content-Type' => 'application/json' })

    parsed_response = response.parsed_response

    return parsed_response if SUCCESS_CODES.include?(response.code)

    error = parsed_response['error']

    begin
      process_api_error(parsed_response, response.code)
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end

  def self.acknowledge_order(klarna_id)

    url = KLARNA_ORDER_MGMT_URL + "#{klarna_id}" + '/acknowledge'

    response = HTTParty.post(url,
                             basic_auth: auth,
                             headers: { 'Content-Type' => 'application/json' })

    return if SUCCESS_CODES.include?(response.code)

    error = response.parsed_response['error']

    begin
      process_api_error(parsed_response, response.code)
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end

  def self.capture_order(klarna_id, payment_amount)

    url = KLARNA_ORDER_MGMT_URL + "#{klarna_id}" + '/captures'

    response = HTTParty.post(url,
                             basic_auth: auth,
                             headers: { 'Content-Type' => 'application/json' },
                             body: { captured_amount: payment_amount }.to_json)

    return if SUCCESS_CODES.include?(response.code)

    parsed_response = response.parsed_response
    error = response.parsed_response['error']

    begin
      process_api_error(parsed_response, response.code)
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end
  end

  def self.auth
    { username: KLARNA_API_AUTH_USERNAME, password: KLARNA_API_AUTH_PASSWORD }
  end

  def self.process_api_error(parsed_response, response_code)
    if error = parsed_response['error']
      raise "KlarnaService error: #{error['type']}, #{error['message']}"
    elsif parsed_response['error_code']
      raise "KlarnaService error: #{parsed_response['error_code']}, #{parsed_response['error_messages']}"
    elsif response_code == 401
      raise "KlarnaService error: authorization failure"
    else
      raise 'Unknown error'
    end
  end

  private_class_method def self.order_json(payment_data)

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
        body: { customer_account_info: [ { unique_account_identifier: payment_data[:user_id] } ] }.to_json,
        content_type: "application/vnd.klarna.internal.emd-v2+json"
      },
      purchase_country: country,
      purchase_currency: payment_data[:currency],
      order_amount: payment_data[:item_price],
      order_tax_amount: 0,
      merchant_reference1: payment_data[:user_id],
      merchant_reference2: payment_data[:id],
      order_lines: [
        {
          type: 'digital',
          name: payment_data[:paid_item],
          quantity: 1,
          unit_price: payment_data[:item_price],
          tax_rate: 0,
          total_amount: payment_data[:item_price],
          total_tax_amount: 0,
        } ],
      merchant_urls: {
        terms: 'https://hitta.sverigeshundforetagare.se/dokument/innehall/hmarket',
        checkout: payment_data[:urls][:checkout],
        confirmation: payment_data[:urls][:success],
        push: payment_data[:urls][:webhook]
      }
    }.to_json

  end
end
