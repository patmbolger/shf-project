# frozen_string_literal: true

class FetchEventsFromDinkursJob < ApplicationJob
  queue_as :default

  def perform(company)
    Dinkurs::EventsCreator.new(company, update_after_date(company)).call
  end


  def update_after_date(company)
    @update_after_date ||= company.event_start_date
  end
end
