class PaymentsController < ApplicationController

  include RobotsMetaTagShowActionOnly

  class NotAuthorizedError < Pundit::NotAuthorizedError
  end

  protect_from_forgery except: :webhook

  def create
    # The user wants to pay a fee (e.g. membership fee or branding fee)
    payment_type = params[:type]
    user_id      = params[:user_id]
    company_id   = params[:company_id] # if h-branding fee to be paid

    authorize Payment.new(user_id: user_id)

    if payment_type == Payment::PAYMENT_TYPE_MEMBER
      start_date, expire_date = User.next_membership_payment_dates(user_id)
      paid_item = I18n.t('payment.payment_type.member_fee')
      item_price = SHF_MEMBER_FEE
    else
      start_date, expire_date = Company.next_branding_payment_dates(company_id)
      paid_item = I18n.t('payment.payment_type.branding_fee')
      item_price = SHF_BRANDING_FEE
    end

    payment = Payment.create!(payment_type: payment_type,
                              user_id: user_id,
                              company_id: company_id,
                              status: Payment.order_to_payment_status(nil),
                              start_date: start_date,
                              expire_date: expire_date)

    payment_data = { id: payment.id,
                     type: payment_type,
                     currency: 'SEK',
                     item_price: item_price,
                     paid_item: paid_item,
                     urls:  klarna_order_urls(payment.id, user_id,
                                              company_id, payment_type) }

    # Invoke Klarna API - returns an order to be used for checkout
    klarna_order = KlarnaService.create_order(payment_data)

    # Save payment and render checkout form
    klarn_id = klarna_order['order_id']
    payment.klarna_id = klarn_id
    payment.status = Payment.order_to_payment_status(klarna_order['status'])
    payment.save!

    @html_snippet = klarna_order['html_snippet']

  rescue RuntimeError, HTTParty::Error, ActiveRecord::RecordInvalid  => exc
    payment.destroy if payment&.persisted?

    log_klarna_activity('create order', 'error', nil, klarna_id, exc)

    log_klarna_activity('create order', 'error', nil, klarna_id, exc.cause)

    helpers.flash_message(:alert, t('.something_wrong',
                                    admin_email: ENV['SHF_REPLY_TO_EMAIL']))

    redirect_back fallback_location: root_path
  end

  def webhook

    # get klarna ID from params
    # get order from Klarna https://developers.klarna.com/api/#order-management-api-get-order
    # get order status
    # save updated Payment record (create it if it doesn't exist??)
    # acknowledge the order back to Klarna (will stop push notifications)

    # "you need to capture the order in order to finalize the payment.
    # The order can be found at Klarna’s Merchant Portal or you can integrate
    # with our Order Management platform using the APIs provided."
    # https://developers.klarna.com/api/#order-management-api-create-capture

    # https://developers.klarna.com/documentation/klarna-checkout/in-depth/confirm-purchase/


    payload = JSON.parse(request.body.read)

    return head(:ok) unless payload['event'] == SUCCESSFUL_klarna_order_EVENT

    resource = HipsService.validate_webhook_origin(payload['jwt'])

    payment_id = resource['merchant_reference']['order_id']
    klarna_id    = resource['id']

    payment = Payment.find(payment_id)
    payment.update(status: Payment.order_to_payment_status(resource['status']))

    log_klarna_activity('Webhook', 'info', payment_id, klarna_id)

  rescue RuntimeError, JWT::IncorrectAlgorithm => exc
    log_klarna_activity('Webhook', 'error', payment_id, klarna_id, exc)

  ensure
    head :ok
  end

  def success

    # Ackowledge the order to Klarna
    # https://developers.klarna.com/api/#order-management-api-acknowledge-order

    payment = Payment.find(params[:id])
    payment.successfully_completed
    helpers.flash_message(:notice, t('.success'))

    klarna_order = KlarnaService.get_order(params[:order_id])
    @html_snippet = klarna_order['html_snippet']
    # redirect_on_payment_success_or_error(payment)
  end

  def error
    helpers.flash_message(:alert, t('.error'))
    payment = Payment.find(params[:id])
    redirect_on_payment_success_or_error(payment)
  end

  private

  def redirect_on_payment_success_or_error(payment)

    if payment.payment_type == Payment::PAYMENT_TYPE_MEMBER
      redirect_to user_path(params[:user_id])
    else
      redirect_to company_path(payment.company_id)
    end
  end

  def log_klarna_activity(activity, severity, payment_id, klarna_id, exc=nil)
    ActivityLogger.open(KLARNA_LOG, 'KLARNA_API', activity, false) do |log|
      log.record(severity, "Payment ID: #{payment_id}") if payment_id
      log.record(severity, "Klarna ID: #{klarna_id}") if klarna_id
      log.record(severity, "Exception class: #{exc.class}") if exc
      log.record(severity, "Exception message: #{exc.message}") if exc
    end
  end

  def klarna_order_urls(payment_id, user_id, company_id, payment_type)
    urls = {}
    urls[:checkout] = payments_url(user_id: user_id, company_id: company_id,
                                   type: payment_type)

    urls[:success] = payment_success_url(id: payment_id,
                                         user_id: user_id,
                                         disable_language_change: true,
                                         klarna_id: '{checkout.order.id}')

    urls[:webhook] = (SHF_WEBHOOK_HOST || root_url) +
                      payment_webhook_path(klarna_id: '{checkout.order.id}').sub('/en', '')
    urls
  end
end
