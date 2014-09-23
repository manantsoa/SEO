class Page < ActiveRecord::Base
	belongs_to :site
	has_many  :hxes        , :dependent => :destroy
	has_many  :titles      , :dependent => :destroy
	has_many  :imgs        , :dependent => :destroy
	has_many  :html_errors , :dependent => :destroy
	has_many  :seoerrors   , :dependent => :destroy
end
