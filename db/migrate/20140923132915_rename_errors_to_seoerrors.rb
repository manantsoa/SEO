class RenameErrorsToSeoerrors < ActiveRecord::Migration
  def change
  	rename_table :errors, :seoerrors
  end
end
