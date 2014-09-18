class Title < ActiveRecord::Base
	belongs_to :page
	has_one    :site, through: :page
end
