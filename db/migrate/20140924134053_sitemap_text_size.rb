class SitemapTextSize < ActiveRecord::Migration
  def change
  	  	remove_column :sitemaps, :str
  	  	add_column :sitemaps, :str, :text
  end
end
