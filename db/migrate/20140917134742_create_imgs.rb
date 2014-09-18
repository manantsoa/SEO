class CreateImgs < ActiveRecord::Migration
  def change
    create_table :imgs do |t|
      t.string :url
      t.string :title
      t.string :alt
      t.integer :page_id
      
      t.timestamps
    end
  end
end
