class CreateHtmlErrors < ActiveRecord::Migration
  def change
    create_table :html_errors do |t|
      t.string :str
      t.integer :line
      t.integer :page_id

      t.timestamps
    end
  end
end
