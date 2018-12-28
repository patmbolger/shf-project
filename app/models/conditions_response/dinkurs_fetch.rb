# Backup code and DB data in production

class DinkursFetch < ConditionResponder

  def self.condition_response(condition, log)

    unless timing_is_every_day?(get_timing(condition))
      msg = "Cannot handle timing other than #{TIMING_EVERY_DAY}"
      log.record('error', msg)
      raise ArgumentError, msg
    end

    Company.where.not(dinkurs_company_id: [nil, '']).order(:id).each do |company|

      company.fetch_dinkurs_events
      company.reload
      log.record('info', "Company #{company.id}: #{company.events.count} events.")

    end

  end

end
