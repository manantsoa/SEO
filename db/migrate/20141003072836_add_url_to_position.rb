class AddUrlToPosition < ActiveRecord::Migration
  def change
  	add_column :positions, :url, :string
  end
end
