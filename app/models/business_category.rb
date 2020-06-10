class BusinessCategory < ApplicationRecord
  has_ancestry

  validates_presence_of :name

  has_and_belongs_to_many :shf_applications
  has_many :companies, through: :shf_applications

  def self.for_search
    categories = []

    roots.order(:name).each do |category|
      categories << category
      categories += category.children.order(:name)
    end

    categories
  end

  def search_name
    return name if is_root?

    parent.name + ' >> ' + name
  end

end
