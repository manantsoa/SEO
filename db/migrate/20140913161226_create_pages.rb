class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :url
      t.text :rawContent
      t.timestamps
    end
  end
end
