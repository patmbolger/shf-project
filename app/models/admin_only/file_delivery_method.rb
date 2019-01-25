module AdminOnly

  class FileDeliveryMethod < ApplicationRecord

    validates :description_sv, presence: true

    def self.default_description_method
      :description_sv
    end
  end
end
