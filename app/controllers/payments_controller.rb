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

    @payment = Payment.create!(payment_type: payment_type,
                               user_id: user_id,
                               company_id: company_id,
                               status: Payment.order_to_payment_status(nil),
                               payment_processor: Payment::PAYMENT_PROCESSOR_KLARNA,
                               start_date: start_date,
                               expire_date: expire_date)

    payment_data = { id: @payment.id,
                     user_id: user_id,
                     type: payment_type,
                     currency: 'SEK',
                     item_price: item_price,
                     paid_item: paid_item,
                     urls:  klarna_order_urls(@payment.id, user_id,
                                              company_id, payment_type) }

    # Invoke Klarna API - returns an order to be used for checkout
    klarna_order = KlarnaService.create_order(payment_data)

    # Save payment and render checkout form
    klarna_id = klarna_order['order_id']
    @payment.klarna_id = klarna_id
    @payment.status = Payment.order_to_payment_status(klarna_order['status'])
    @payment.save!

    log_klarna_activity('Create Order', 'info', @payment.id, klarna_id)

    @html_snippet = klarna_order['html_snippet']

    raise 'This is a test exception'

  rescue RuntimeError, HTTParty::Error, ActiveRecord::RecordInvalid  => exc
    @payment.destroy if @payment&.persisted?

    log_klarna_activity('create order', 'error', nil, klarna_id, exc)

    log_klarna_activity('create order', 'error', nil, klarna_id, exc.cause)

    helpers.flash_message(:alert, t('.something_wrong',
                                    admin_email: ENV['SHF_REPLY_TO_EMAIL']))

    notify_slack_of_exception(exc, __method__)

    SHFNotifySlack.failure_notification("#{self.class.name}\##{__method__}",
                                        text: exc.message)

    redirect_back fallback_location: root_path
  end

  def success
    # This is the klarna "confirmation" action.
    # https://developers.klarna.com/documentation/klarna-checkout/in-depth/confirm-purchase

    klarna_id = params[:klarna_id]
    payment_id = params[:id]

    klarna_order = handle_order_confirmation

    account_page_link = helpers.link_to(t('menus.nav.users.your_account').downcase,
                                        user_path(params[:user_id]))

    helpers.flash_message(:notice, t('.success_html',
                                     account_page_link: account_page_link))

    log_klarna_activity('Order Confirmation', 'info', payment_id, klarna_id)

    @html_snippet = klarna_order['html_snippet']

  rescue RuntimeError => exc
    log_klarna_activity('Order Confirmation', 'error', payment_id, klarna_id, exc)
    notify_slack_of_exception(exc, __method__)
  end

  def webhook
    # This is the klarna "push" action.  It is the "fallback" action in case
    # the "confirmation" action (see "success" method here) does not occur.
    # https://developers.klarna.com/documentation/klarna-checkout/in-depth/confirm-purchase/

    # Fetch the order (Order Management API) and check if "captured_amount" is
    # zero:
    #    If so, do nothing (order has been acknowledged and order amount captured).
    #    Otherwise, perform same actions as for "success" action.

    klarna_id = params[:klarna_id]
    payment_id = params[:id]

    klarna_order = KlarnaService.get_order(klarna_id)

    return if klarna_order['captured_amount'] != 0

    handle_order_confirmation

    log_klarna_activity('Webhook', 'info', payment_id, klarna_id)

  rescue RuntimeError => exc
    log_klarna_activity('Webhook', 'error', payment_id, klarna_id, exc)
    notify_slack_of_exception(exc, __method__)
  ensure
    head :ok
  end

  private

  def handle_order_confirmation

    klarna_id = params[:klarna_id]

    klarna_order = KlarnaService.get_checkout_order(klarna_id)

    KlarnaService.acknowledge_order(params[:klarna_id])

    payment = Payment.find(params[:id])
    payment.update_attribute(:status,
                             Payment.order_to_payment_status(klarna_order['status']))
    payment.successfully_completed

    # Capture the order in Klarna (indicates the order has been filled and
    # payment settlement can occur)
    KlarnaService.capture_order(klarna_id, klarna_order['order_amount'])

    klarna_order
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
                      payment_webhook_path(id: payment_id,
                                           klarna_id: '{checkout.order.id}').sub('/en', '')
    urls
  end

  def notify_slack_of_exception(exc, method_sym)
    SHFNotifySlack.failure_notification("#{self.class.name}\##{method_sym}",
                                        text: exc.message)
  end
end
