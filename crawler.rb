require 'rubygems'
# Base de donnés 
require 'mysql'
require 'yaml'
require 'active_record'
# HTTP Parser 
require 'nokogiri'
# Connexion au site
require 'anemone'
require 'benchmark'


# Erreurs

HX_ORDER = 1
HX_DUPLICATE = 2
HX_DIFF = 3

# Connexion Database

y = YAML.load_file('./config/database.yml')["development"]
ActiveRecord::Base.establish_connection(y)

# Classes ActiveRecord
 
class Site < ActiveRecord::Base
  has_many :pages                         , :dependent => :destroy
  has_many  :hxes        , through: :pages, :dependent => :destroy
  has_many  :titles      , through: :pages, :dependent => :destroy
  has_many  :imgs        , through: :pages, :dependent => :destroy
  has_many  :seoerrors   , through: :pages, :dependent => :destroy
  has_many  :html_errors , through: :pages, :dependent => :destroy
end

class Page < ActiveRecord::Base
	belongs_to :site
	has_many  :hxes        , :dependent => :destroy
  has_many  :titles      , :dependent => :destroy
  has_many  :imgs        , :dependent => :destroy
  has_many  :html_errors , :dependent => :destroy
  has_many  :seoerrors   , :dependent => :destroy
end

class Hx < ActiveRecord::Base
	belongs_to :page
  has_one    :site, through: :page
end

class Title < ActiveRecord::Base
  belongs_to :page
  has_one    :site, through: :page
end

class Img < ActiveRecord::Base
  belongs_to :page
  has_one    :site, through: :page
end

class HtmlError < ActiveRecord::Base
  belongs_to :page
  has_one    :site, through: :page
end

class Seoerror < ActiveRecord::Base
  belongs_to :page
  has_one    :site, through: :page
end

# Main

mArgv = ARGV
if mArgv[0].nil?
  Site.all.each { |s| mArgv.append(s.url)}
end
mArgv.each do |url|
  if (site = Site.find_by(url:url)) == nil
	  site = Site.create
  end
  site.url = url
  if !site || !site.url
    return
  end
  Anemone.crawl(site.url, :threads => 8, :verbose => true, :obey_robots_txt => true) do |anemone|
   	anemone.on_every_page do |page|
      if page.html? && page.code.to_i == 200
      	if (p = site.pages.find_by(url:page.url.to_s)) == nil
  		 	  p = site.pages.create
  			  p.url = page.url.to_s
  		  end
        p.site_id = site.id
        p.seoerrors.delete_all
        p.html_errors.delete_all
        p.hxes.delete_all
        p.titles.delete_all
        doc = Nokogiri::HTML(page.body, nil, nil, 1 | 1 << 11)
        # Erreurs HTML
        doc.errors.each do |e|
          p.html_errors.create(str:e.to_s, line:e.line, page_id:p.id)
        end
        # Hx
   	    hx = []
	   	  (1..6).each do |x|
    	 		hx += doc.css("h" + x.to_s)
           hx.each {|h| h[:x] = x.to_i if h[:x].nil?}
   	    end
        if hx.count > 0
          hx = hx.sort_by {|a| a[:line]}
          prv = hx[0][:x]
          maxHx = prv
          orderRem = 0
          (0..hx.count - 1).each do |idx|
            p.seoerrors.create(code: HX_DIFF, line:hx[idx].line, page_id: p.id, site_id: p.site.id) unless (hx[idx][:x].to_i - prv.to_i).abs <= 1.to_i
            unless (hx[idx][:x] >= maxHx || orderRem)
              p.seoerrors.create(code: HX_ORDER, line:hx[idx].line, page_id: p.id, site_id: p.site.id)  		 
              orderRem = 1
            end
            p.hxes.create(x:hx[idx][:x], pos:hx[idx].line, content:(hx[idx].text != nil.to_s ? hx[idx].text.to_s : "Erreur HTML sur la balise"), page_id:p.id) rescue nil
            prv = hx[idx][:x]
          end
        end
        # Title
        doc.css("title").each do |t|
          p.titles.create(content:t.content, page_id:p.id)
        end
        # Images
        p.imgs.delete_all
        doc.css("img").each do |i|
        p.imgs.create(url:i[:src], title:i[:title], alt:i[:alt], page_id:p.id)
      end
 		  p.save
 	  end
  end
  dupCheck = site.hxes.all.uniq! {|l| l.content}
  dupCheck.each { |e| e.page.seoerrors.create(code:HX_DUPLICATE, line: e[:line], page_id: e.page.id, site_id: e.page.site.id)} 
  end
  site.save
end
puts "Done."
exit(0)