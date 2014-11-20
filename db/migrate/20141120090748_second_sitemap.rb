class SecondSitemap < ActiveRecord::Migration
  def change
    add_column :sites, :sitemap_image, :integer
  end
end
