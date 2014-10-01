class Historique < ActiveRecord::Migration
  def change
  	remove_column :positions, :query
  	rename_column :positions, :site_id, :query_id
  end
end
