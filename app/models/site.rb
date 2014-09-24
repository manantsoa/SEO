class Site < ActiveRecord::Base
	has_many :pages, :dependent => :destroy
	has_many  :hxes  , through: :pages, :dependent => :destroy
	has_many  :titles, through: :pages, :dependent => :destroy
	has_many  :seoerrors, through: :pages, :dependent => :destroy
end
