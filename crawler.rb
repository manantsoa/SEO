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
require 'benchmark'

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
  puts Benchmark.measure {
 	  if (site = Site.find_by(url:ARGV[0])) == nil
	 	  site = Site.create
		  site.url = ARGV[0]
	  end
    replies = []
    Anemone.crawl(site.url, :threads => 12, :verbose => true, :obey_robots_txt => true) do |anemone|
  		anemone.on_every_page do |page|
  		  if replies[page.code] == nil
          replies[page.code] = 0
        end
        replies[page.code] += 1
        if page.html? and page.code == 200
  		  	if (p = site.pages.find_by(url:page.url.to_s)) == nil
  			 	  p = site.pages.create
  				  p.url = page.url.to_s
  			  end
  		    p.rawContent = page.doc.to_s
  		    p.site_id = site.id
  		    p.hxes.destroy_all
 		 		  hx = []
   		 	  (1..6).each do |x|
   		 	  	s = "h" + x.to_s
   		 		  page.doc.css(s).each do |h|
   		 		 	  hx.append({x:x, idx:page.doc.to_s.index(h.to_s), content:h.content})
   		      end
   		 	  end
          hx = hx.sort { |a, b| a[:idx] <=> b[:idx]}
 	  		  (0..hx.count - 1).each do |idx|
 		  		  if p.hxes.create(x:hx[idx][:x], pos:idx + 1, content:hx[idx][:content], page_id:p.id) == false
 						  puts "Impossible d'enregistrer hx dans la base de donnée"	
 					  end
 	  		  end
 	  		  p.save
 	  	  end
 		  end
  	end
	  site.save
    puts "Done. pages replies : "
    rpcode = 0
    (100..520).each {|r| puts ("Code [" + r.to_s + "] : " + replies[r].to_s) unless replies[r].nil?}
  }
	exit(0)
end
exit(1)