class Addtmp < ActiveRecord::Migration
  def change
    add_column :sites, :processing, :integer
  end
end
