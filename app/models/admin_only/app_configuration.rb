module AdminOnly

  class AppConfiguration < ApplicationRecord
    # Aggregates discrete data items that are used to configure
    # various aspects of the system (app).

    has_attached_file :chair_signature,
                      url: :url_for_images,
                      default_url: 'chair_signature.png',
                      styles: { standard: ['180x40#'] },
                      default_style: :standard

    has_attached_file :shf_logo,
                      url: :url_for_images,
                      default_url: 'shf_logo.png',
                      styles: { standard: ['257x120#'] },
                      default_style: :standard

    has_attached_file :h_brand_logo,
                      url: :url_for_images,
                      default_url: 'h_brand_logo.png',
                      styles: { standard: ['248x240#'] },
                      default_style: :standard

    has_attached_file :sweden_dog_trainers,
                      url: :url_for_images,
                      default_url: 'sweden_dog_trainers.png',
                      styles: { standard: ['234x39#'] },
                      default_style: :standard

    validates_attachment_content_type :chair_signature, :shf_logo,
                                      :h_brand_logo, :sweden_dog_trainers,
                                      content_type:  /\Aimage\/.*(jpeg|png)\z/

    validates_attachment_file_name :chair_signature, :shf_logo,
                                   :h_brand_logo, :sweden_dog_trainers,
                                   matches: [/png\z/, /jpe?g\z/]

    private

    def url_for_images
      '/storage/app_configuration/images/:attachment/:hashed_path/:style_:basename.:extension'
    end
  end
end
