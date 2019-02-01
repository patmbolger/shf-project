module AdminOnly

  class FileDeliveryMethod < ApplicationRecord

    METHOD_NAMES = {
      upload_now: 'upload_now',
      upload_later: 'upload_later',
      email: 'email',
      mail: 'mail',
      files_uploaded: 'files_uploaded'
    }.freeze

    has_many :shf_applications, dependent: :nullify

    validates :description_en, :description_sv, presence: true

    validates :name, presence: true,
                     inclusion: { in: METHOD_NAMES.values }

    validates :default_option, uniqueness: true,
              :if => Proc.new { |record| record.default_option }

    scope :default, -> { where(default_option: true) }

  end
end
