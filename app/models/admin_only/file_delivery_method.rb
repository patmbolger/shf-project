module AdminOnly

  class FileDeliveryMethod < ApplicationRecord

    METHOD_NAMES = {
      upload_now: 'upload_now',
      upload_later: 'upload_later',
      email: 'email',
      mail: 'mail',
      files_uploaded: 'files_uploaded'
    }

    has_many :shf_applications, dependent: :nullify

    validates :description_en, :description_sv, presence: true

    validates :name, presence: true, uniqueness: :true

    validates :default_option, uniqueness: true,
              :if => Proc.new { |record| record.default_option }

  end
end
