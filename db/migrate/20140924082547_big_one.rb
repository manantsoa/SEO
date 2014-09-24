class BigOne < ActiveRecord::Migration
  def change
  	drop_table :html_errors
  	drop_table :imgs
  	remove_column :pages, :rawContent
  end
end
