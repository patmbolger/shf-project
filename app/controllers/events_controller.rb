class EventsController < ApplicationController
  before_action :set_company

  def fetch_from_dinkurs
    raise 'Unsupported request' unless request.xhr?

    authorize Event.new(company: @company)

    @company.fetch_dinkurs_events
    @company.reload

    render partial: 'events/teaser_list',
           locals: { events: @company.events.order(:start_date) }
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end
end
