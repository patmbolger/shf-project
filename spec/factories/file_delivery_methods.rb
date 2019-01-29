FactoryBot.define do
  factory :file_delivery_method, class: AdminOnly::FileDeliveryMethod do
    description_sv { "Ladda upp nu" }
    description_en { "Upload now" }
    default_option { true }
  end
end
