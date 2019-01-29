module AdminOnly

  class FileDeliveryMethod < ApplicationRecord

    has_many :shf_applications, class_name: 'ShfApplication' ,
                                dependent: :nullify

    validates :description_sv, presence: true

    validates :default_option, uniqueness: true,
              :if => Proc.new { |record| record.default_option }

    def self.default_description_method
      :description_sv
    end
  end
end
