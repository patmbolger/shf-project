class AddAddressVisibilityToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :address_visibility, :string, default: 'Gata'
  end
end
