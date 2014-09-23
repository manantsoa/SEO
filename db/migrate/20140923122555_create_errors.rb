class CreateErrors < ActiveRecord::Migration
  def change
    create_table :errors do |t|
      t.integer :type
      t.integer :line
      t.integer :page_id
      t.integer :site_id
      t.string :desc

      t.timestamps
    end
  end
end
