# Set the initial values for shf_application file delivery methods (user chooses
# how to deliver files associated with his or her application)

# NOTE: These records should NOT include a record that specifies that the user
#       will upload the files with the current application "save".
#       That is the "default" action and is expected by the controller *unless*
#       the user selects an alternative delivery method in the UI.

namespace :shf do
  namespace :one_time do

    desc "Initialize file delivery methods"
    task set_file_delivery_methods: :environment do

      delivery_methods = [

        { description_sv: 'Ladda upp filer senare',
          description_en: 'Upload files later' },

        { description_sv: 'Skicka via e-post (till adress nedan)',
          description_en: 'Send via email (to address below)' },

        { description_sv: 'Skicka via vanlig post (till adress nedan)',
          description_en: 'Send via regular mail (to address below)' }
      ]

      log_file = 'log/set_file_delivery_methods.log'

      ActivityLogger.open(log_file, 'App Files', 'set delivery methods') do |log|

        delivery_methods.each do |rec|
          AdminOnly::FileDeliveryMethod.create!(rec)
        end

        log.record('info', "Created #{delivery_methods.size} records.")

      end
    end
  end
end
