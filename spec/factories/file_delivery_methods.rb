FactoryBot.define do
  factory :file_delivery_upload_now, class: AdminOnly::FileDeliveryMethod do
    name { AdminOnly::FileDeliveryMethod::METHOD_NAMES[:upload_now] }
    description_sv { 'Ladda upp nu' }
    description_en { 'Upload now' }
    default_option { true }
  end

  factory :file_delivery_upload_later, class: AdminOnly::FileDeliveryMethod do
    name { AdminOnly::FileDeliveryMethod::METHOD_NAMES[:upload_later] }
    description_sv { 'Ladda upp senare' }
    description_en { 'Upload later' }
  end

  factory :file_delivery_email, class: AdminOnly::FileDeliveryMethod do
    name { AdminOnly::FileDeliveryMethod::METHOD_NAMES[:email] }
    description_sv { 'Skicka via e-post' }
    description_en { 'Send via email' }
  end

  factory :file_delivery_mail, class: AdminOnly::FileDeliveryMethod do
    name { AdminOnly::FileDeliveryMethod::METHOD_NAMES[:mail] }
    description_sv { 'Skicka via vanlig post' }
    description_en { 'Send via regular mail' }
  end

  factory :file_delivery_files_uploaded, class: AdminOnly::FileDeliveryMethod do
    name { AdminOnly::FileDeliveryMethod::METHOD_NAMES[:files_uploaded] }
    description_sv { 'Alla filer laddas upp' }
    description_en { 'All files are uploaded' }
  end

  trait :skip_validation do
    to_create {|instance| instance.save(validate: false)}
  end
end
