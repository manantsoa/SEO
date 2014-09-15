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
end

class Page < ActiveRecord::Base
end

class Hx < ActiveRecord::Base
end

unless ARGV[0].nil? 
	Anemone.crawl("http://assurance-cyclo-scooter.com/", :threads => 12, :verbose => true, :obey_robots_txt => true) do |anemone|
  		anemone.on_every_page do |page|
  			if page.html?
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
    	  			puts "<h"+hx[idx - 1][:x].to_s+">" + hx[idx - 1][:content] + "</h"+hx[idx - 1][:x].to_s+">"
       	  		end
       	  	end
  		end
	end
	exit(0)
end
exit(1)