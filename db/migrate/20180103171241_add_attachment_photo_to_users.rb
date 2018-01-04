class AddAttachmentPhotoToUsers < ActiveRecord::Migration[5.1]
  def self.up
    add_attachment :users, :photo
  end

  def self.down
    remove_attachment :users, :photo
  end
end
