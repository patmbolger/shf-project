RSpec.shared_context 'create file delivery methods' do

  let!(:upload_now) { create(:file_delivery_upload_now) }

  let!(:upload_later) { create(:file_delivery_upload_later) }

  let!(:email) { create(:file_delivery_email) }

  let!(:mail) { create(:file_delivery_mail) }

  let!(:files_uploaded) { create(:file_delivery_files_uploaded) }

end
