require 'rubygems'
# Base de donnés 
require 'sqlite3'
require 'active_record'
# HTTP Parser 
require 'nokogiri'
# Connexion au site
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
	has_many  :hxes        , :dependent => :destroy
  has_many  :titles      , :dependent => :destroy
  has_many  :imgs        , :dependent => :destroy
  has_many  :html_errors , :dependent => :destroy
end

class Hx < ActiveRecord::Base
	belongs_to :page
end

class Title < ActiveRecord::Base
  belongs_to :page
end

class Img < ActiveRecord::Base
  belongs_to :page
end

class HtmlError < ActiveRecord::Base
  belongs_to :page
  has_one    :site, through: :page
end


mArgv = ARGV
if mArgv[0].nil?
  Site.all.each { |s| mArgv.append(s.url)}
end
puts Benchmark.measure {
  mArgv.each do |url|
    if (site = Site.find_by(url:url)) == nil
	 	  site = Site.create
		  site.url = url
	  end
    if !site || !site.url
      return
    end
    replies = []
    Anemone.crawl(site.url, :threads => 8, :verbose => true, :obey_robots_txt => true) do |anemone|
  		anemone.on_every_page do |page|
        if page.url == site.url + "index.html"
          next
        end
  		  if replies[page.code] == nil
          replies[page.code] = 0
        end
        replies[page.code] += 1
        if page.html? && page.code == 200
  		  	if (p = site.pages.find_by(url:page.url.to_s)) == nil
  			 	  p = site.pages.create
  				  p.url = page.url.to_s
  			  end
          doc = Nokogiri::HTML(page.body, nil, nil, 1 | 1 << 11)
#          doc.errors.each {|e| puts e.to_s + e.line.to_s}
          p.html_errors.delete_all
          doc.errors.each do |e|
            p.html_errors.create(str:e.to_s, line:e.line, page_id:p.id)
          end
#  		            p.rawContent = page.body
  		    p.site_id = site.id
          Benchmark.bm() do |measure|
            measure.report("<hx>    ") {
      		    p.hxes.delete_all
 	    	 		  hx = []
   		    	  (1..6).each do |x|
    		 		      hx += doc.css("h" + x.to_s)
#                  hx.append({x:x, idx:h.line, content:(h.text != nil.to_s ? h.text : "Erreur HTML sur la balise")})
   		     	  end
              hx = hx.sort_by {|a| a[:line]}
              (0..hx.count - 1).each do |idx|
 		  		       p.hxes.create(x:hx[idx][:x],
                                 pos:hx[idx].line,
                                 content:(hx[idx].text != nil.to_s ? hx[idx].text : "Erreur HTML sur la balise"),
                                 page_id:p.id)
 					    end
            }
            measure.report("<title>") {
              p.titles.delete_all
              doc.css("title").each do |t|
                p.titles.create(content:t.content, page_id:p.id)
              end
            }
            measure.report("<img>   ") {
              p.imgs.delete_all
              doc.css("img").each do |i|
                p.imgs.create(url:i[:src], title:i[:title], alt:i[:alt], page_id:p.id)
              end
            }
          end
 	  		  p.save
 	  	  end
 		  end
  	end
	  site.save
    puts "Done. pages replies : "
    if replies[200] == 0
      site.destroy
    end
    rpcode = 0
    (100..520).each {|r| puts ("Code [" + r.to_s + "] : " + replies[r].to_s) unless replies[r].nil?}
  end
}
exit(0)