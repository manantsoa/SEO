class Page < ActiveRecord::Base
	belongs_to :site
	has_many  :hxes, :dependent => :destroy
end
