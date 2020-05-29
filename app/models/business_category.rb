class BusinessCategory < ApplicationRecord
  has_ancestry

  validates_presence_of :name

  has_and_belongs_to_many :shf_applications
  has_many :companies, through: :shf_applications

  def self.for_search
    categories = roots.order(:name).to_a
    categories.dup.each_with_index do |category, idx|
      categories.insert(idx+1, category.children)
    end
    categories.flatten
  end

  def search_name
    return name if is_root?

    parent.name + ' >> ' + name
  end
end
