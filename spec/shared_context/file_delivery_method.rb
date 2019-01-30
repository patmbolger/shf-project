RSpec.shared_context 'create file delivery methods' do

  let(:upload_method) { create(:file_delivery_method) }

  let(:upload_later_method) do
    create(:file_delivery_method, default_option: false,
           name: AdminOnly::FileDeliveryMethod::METHOD_NAMES[:upload_later],
           description_sv: 'upload later in Swedish',
           description_en: 'upload later in English')
  end

  let(:email_method) do
    create(:file_delivery_method, default_option: false,
           name: AdminOnly::FileDeliveryMethod::METHOD_NAMES[:email],
           description_sv: 'email in Swedish',
           description_en: 'email in English')
  end

  let(:mail_method) do
    create(:file_delivery_method, default_option: false,
           name: AdminOnly::FileDeliveryMethod::METHOD_NAMES[:mail],
           description_sv: 'mail in Swedish',
           description_en: 'mail in English')
  end

  let(:files_uploaded) do
    create(:file_delivery_method, default_option: false,
           name: AdminOnly::FileDeliveryMethod::METHOD_NAMES[:files_uploaded],
           description_sv: 'files uploaded in Swedish',
           description_en: 'files uploaded in English')
  end

end
