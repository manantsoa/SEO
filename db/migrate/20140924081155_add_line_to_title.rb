class AddLineToTitle < ActiveRecord::Migration
  def change
  	add_column :titles, :line, :integer
  end
end
