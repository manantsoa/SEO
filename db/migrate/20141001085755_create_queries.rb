class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string :query
      t.integer :site_id

      t.timestamps
    end
  end
end
