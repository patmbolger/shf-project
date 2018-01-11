class CreateApplicationCompanyJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :shf_applications, :companies do |t|
      t.index [:shf_application_id, :company_id]
      t.index [:company_id, :shf_application_id]
    end
  end
end
