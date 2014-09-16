require 'rubygems'
# Base de donnés 
require 'sqlite3'
require 'active_record'
# HTTP Parser 
require 'nokogiri'
# Connexion au site
require 'open-uri'
require 'addressable/uri'
require 'anemone'

#ActiveRecord::Base.establish_connection(
#  :adapter => "sqlite",
#  :database  => 'C:\Users\Informatique\Desktop\SEO\SEO\db\development.sqlite3'
#)

# Connexion en dur temporaire a l abase de donnés de dev

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :host     => "",
  :username => "",
  :password => "",
  :database => "./db/development.sqlite3"
)

# Define your classes based on the database, as always
class Site < ActiveRecord::Base
	has_many :pages, :dependent => :destroy
end

class Page < ActiveRecord::Base
	belongs_to :site
	has_many  :hxes, :dependent => :destroy
end

class Hx < ActiveRecord::Base
	belongs_to :page
end

unless ARGV[0].nil? 
	if (site = Site.find_by(url:ARGV[0])) == nil
		site = Site.create
		site.url = ARGV[0]
	end
	Anemone.crawl(site.url, :threads => 12, :verbose => true, :obey_robots_txt => true) do |anemone|
  		anemone.on_every_page do |page|
  			if page.html?
  				if (p = site.pages.find_by(url:page.url.to_s)) == nil
  					p = site.pages.create
  					p.url = page.url.to_s
  				end
  				p.rawContent = page.doc.to_s
  				p.site_id = site.id
  				p.hxes.destroy_all
   		 		#Nokogiri::HTML(page.doc) rescue puts "HTML Translation error"
   		 		# Balises Hx
   		 		hx = []
   		 		(1..6).each do |x|
   		 			s = "h" + x.to_s
   		 			page.doc.css(s).each do |h|
   		 			 	hx.append({x:x, idx:page.doc.to_s.index(h), content:h.content})
   		 			end
   		 		end
       	  		hx.sort_by { |h| h[:idx]} rescue "Hello"
       	  		(1..hx.count).each do |idx|
       		  		if p.hxes.create(x:hx[idx - 1][:x], pos:idx, content:hx[idx - 1][:content], page_id:p.id) == false
 						puts "Impossible d'enregistrer hx dans la base de donnée"	
 					end
    	  		#	puts "<h"+hx[idx - 1][:x].to_s+">" + hx[idx - 1][:content] + "</h"+hx[idx - 1][:x].to_s+">"
       	  		end
       	  		p.save
       	  	end
  		end
	end
	site.save
	exit(0)
end
exit(1)