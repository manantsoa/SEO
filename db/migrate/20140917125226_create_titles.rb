class CreateTitles < ActiveRecord::Migration
  def change
    create_table :titles do |t|
      t.string :content
      t.integer :page_id

      t.timestamps
    end
  end
end
