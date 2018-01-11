class RemoveCompanyIdFromShfApplications < ActiveRecord::Migration[5.1]
  def change
    reversible do |direction|
      direction.up do

        LOG_FILE = 'log/application_has_many_companies'

        ActivityLogger.open(LOG_FILE, 'MIGRATE', 'convert to has_many') do |log|

          apps_converted = 0
          log.record('info', "Checking #{ShfApplication.count} applications.")

          ShfApplication.each do |app|

            next unless app.company_id
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

        remove_column :shf_applications, :company_id
      end

      direction.down do
        add_column :shf_applications, :company_id, :integer
      end
    end
  end
end
