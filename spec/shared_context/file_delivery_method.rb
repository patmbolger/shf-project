RSpec.shared_context 'create file delivery methods' do

  let(:upload_method) { create(:file_delivery_method) }

  let(:upload_later_method) do
    create(:file_delivery_method, default_option: false,
           description_sv: 'upload later in Swedish',
           description_en: 'upload later in English')
  end

  let(:email_method) do
    create(:file_delivery_method, default_option: false,
           description_sv: 'email in Swedish',
           description_en: 'email in English')
  end

  let(:mail_method) do
    create(:file_delivery_method, default_option: false,
           description_sv: 'mail in Swedish',
           description_en: 'mail in English')
  end

end
