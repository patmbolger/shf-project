# frozen_string_literal: true

module Dinkurs
  class EventsCreator
    def initialize(company, events_start_date)
      @company = company
      @events_start_date = events_start_date
    end

    def call
      return unless events_hashes = dinkurs_events_hashes

      events_hashes.each do |event|
        next if event[:start_date] < events_start_date

        Event.create(event)
      end
    end

    private

    attr_reader :company, :events_start_date

    def dinkurs_events_hashes
      Dinkurs::EventsParser
        .new(dinkurs_events.dig('events', 'event'), company.id)
        .call
    end

    def current_events_keys
      @current_events_keys ||= Event.pluck(:dinkurs_id)
    end

    def dinkurs_events
      Dinkurs::Client.new(company.dinkurs_company_id).company_events_hash
    end
  end
end
