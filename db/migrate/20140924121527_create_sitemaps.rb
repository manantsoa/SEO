class CreateSitemaps < ActiveRecord::Migration
  def change
    create_table :sitemaps do |t|
      t.integer :site_id
      t.string :str

      t.timestamps
    end
  end
end
