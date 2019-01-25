class CreateFileDeliveryMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :file_delivery_methods do |t|
      t.string :description_sv
      t.string :description_en

      t.timestamps
    end

    change_table_comment(:file_delivery_methods,
      'User choices for how files for SHF application will be delivered')
  end
end
