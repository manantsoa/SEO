class CreateHxes < ActiveRecord::Migration
  def change
    create_table :hxes do |t|
      t.integer :x
      t.integer :pos
      t.string :content
      t.integer :page_id

      t.timestamps
    end
  end
end
