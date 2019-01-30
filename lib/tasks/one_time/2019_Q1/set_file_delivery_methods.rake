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

        { name: AdminOnly::FileDeliveryMethod::METHOD_NAMES[:upload_now],
          description_sv: 'Ladda upp nu',
          description_en: 'Upload now',
          default_option: true },

        { name: AdminOnly::FileDeliveryMethod::METHOD_NAMES[:upload_later],
          description_sv: 'Ladda upp senare',
          description_en: 'Upload later' },

        { name: AdminOnly::FileDeliveryMethod::METHOD_NAMES[:email],
          description_sv: 'Skicka via e-post',
          description_en: 'Send via email' },

        { name: AdminOnly::FileDeliveryMethod::METHOD_NAMES[:mail],
          description_sv: 'Skicka via vanlig post',
          description_en: 'Send via regular mail' },

        { name: AdminOnly::FileDeliveryMethod::METHOD_NAMES[:files_uploaded],
          description_sv: 'Alla filer laddas upp',
          description_en: 'All files are uploaded' }
      ]

      log_file = 'log/set_file_delivery_methods.log'

      ActivityLogger.open(log_file, 'App Files', 'set delivery methods') do |log|

        AdminOnly::FileDeliveryMethod.destroy_all

        delivery_methods.each do |rec|
          AdminOnly::FileDeliveryMethod.create!(rec)
        end

        log.record('info', "Created #{delivery_methods.size} records.")

      end
    end
  end
end
