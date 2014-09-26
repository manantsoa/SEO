class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string :query
      t.integer :pos
      t.integer :site_id

      t.timestamps
    end
  end
end
