namespace :shf do

  desc "Convert has_one data to has_many association"
  task app_has_many_companies: :environment do

    log_file = 'log/app_has_many_companies'

    ActivityLogger.open(log_file, 'App>>Company', 'convert to has_many') do |log|

      apps_converted = 0
      log.record('info', "Checking #{ShfApplication.count} applications.")

      applications = ShfApplication.where.not(company_id: nil)

      applications.each do |app|
        begin
          app.companies << Company.find(app.company_id)
          apps_converted += 1
        rescue ActiveRecord::RecordNotFound
          log.record('error',
                     "App: #{app.id}, cannot find company: #{app.company_id}")
        end
      end
      log.record('info', "Converted #{apps_converted} applications.")
    end
  end
end
