class RenameColumn < ActiveRecord::Migration
  def change
  	rename_column :seoerrors, :type, :code
  end
end
