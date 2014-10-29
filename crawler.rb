# coding: utf-8
require 'rubygems'
# Base de donnés 
require (`uname` == "Linux\n" ? 'mysql' : 'pg')
require 'yaml'
require 'active_record'
# HTTP Parser 
require 'nokogiri'
# Connexion au site
require 'anemone'
require 'benchmark'
require 'sitemap_generator'
require 'exifr'
require 'ruby-progressbar'

#require 'drb/drb'

$images = []
 #processHost="druby://localhost:8787"
# Erreurs, mets les en dur et je rm ton code !

HX_ORDER             = 1          # Erreur d'ordonancement
HX_DUPLICATE         = 2          # Duplicatat de balise <hx> sut le site
HX_DIFF              = 3          # </h1> <h3> 
PARSER               = 4          # Erreur de Nokogiri
TITLE_DUPLICATE      = 5          # Duplicatat de titre
IMG_NOALT            = 6          # Pas de alt sur une image
TITLE_LENGTH         = 7          # Titre trop long
EXTERNAL_FOLLOW      = 8          # Lien externe sans nofollow
NO_HREF              = 9          # balise <a> sans href
BAD_LINK             = 10         # Lien mal formé qui fait planter le parseur uri
DEAD_LINK            = 11         # Ein 404

# Connexion Database
y = YAML.load_file('./config/database.yml')["development"]
ActiveRecord::Base.establish_connection(y)

# Classes ActiveRecord

class Site < ActiveRecord::Base
  has_many :pages                         , :dependent => :destroy
  has_many  :hxes        , through: :pages, :dependent => :destroy
  has_many  :titles      , through: :pages, :dependent => :destroy
  has_many  :seoerrors                    , :dependent => :destroy
  has_one  :sitemap  , :dependent => :destroy
end

class Sitemap < ActiveRecord::Base
  belongs_to :site
end

class Page < ActiveRecord::Base
  belongs_to :site
  has_many  :hxes        , :dependent => :destroy
  has_many  :titles      , :dependent => :destroy
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

class Seoerror < ActiveRecord::Base
  belongs_to :page
  has_one    :site, through: :page
end

def runPage(page, site)
  if (p = site.pages.find_by(url:page.url.to_s)) == nil
    p = site.pages.create
    p.url = page.url.to_s
  end
  #IO.popen("parser.rb #{site.id} #{p.id}") {|fd| fd.puts page.body}
  p.site_id = site.id
  p.seoerrors.delete_all
  p.hxes.delete_all
  p.titles.delete_all
  doc = Nokogiri::HTML(page.body, nil, nil, 1 | 1 << 11)
  #FRONT_OBJECT = SplitServer.new ([Nokogiri::HTML(page.body, nil, nil, 1 | 1 << 11), p])
  # threads << Thread.new {spawn("ruby img.rb")}
  #threads << Thread.new {spawn("ruby errors.rb")}
  # Erreurs HTML
  $httpErrors.each do |badlink|
    if page.body.include? badlink
      p.seoerrors.create(code: DEAD_LINK, desc: badlink, site_id: p.site.id)
    end
  end
  doc.errors.each do |e|
    unless ["htmlParseEntityRef: expecting ';'", 'Tag video invalid', 'Tag source invalid', 'Tag marquee invalid', 'Namespace prefix gcse is not defined', 'Tag gcse:search invalid', 'Tag gcse:searchbox-only invalid', 'Tag nav invalid'].include?(e.to_s)
      p.seoerrors.create(code: PARSER, desc: e.to_s.force_encoding('utf-8'), line:e.line, page_id:p.id, site_id: p.site.id)
    end
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
      p.seoerrors.create(code: HX_DIFF, line:hx[idx].line, desc: "h"+prv.to_s+" -> h"+hx[idx][:x].to_s, page_id: p.id, site_id: p.site.id) unless (hx[idx][:x].to_i - prv.to_i).abs <= 1.to_i
      unless ((hx[idx][:x] >= maxHx) || (orderRem))
        p.seoerrors.create(code: HX_ORDER, line:hx[idx].line, desc: "Premiere balise de la page : h"+maxHx.to_s+" | balise en erreur : h"+hx[idx][:x], page_id: p.id, site_id: p.site.id)      
        orderRem = 1
      end
      p.hxes.create(x:hx[idx][:x], pos:hx[idx].line, content:(hx[idx].text != nil.to_s ? hx[idx].text.to_s : "Erreur HTML sur la balise"), page_id:p.id) rescue nil
      prv = hx[idx][:x]
        end
  end
  # Title
  doc.css('title').each do |t|
    p.titles.create(content:t.content, line: t.line, page_id:p.id)
    p.seoerrors.create(code:TITLE_LENGTH, line:t.line, desc: t.content.to_s.force_encoding("utf-8")[0..254], page_id:p.id, site_id:p.site.id) unless t.content.size <= 65
  end
  
  hst = URI.parse(site.url).host
  doc.css('a').each do |a|
    if a['href'].nil? or a['href'] == nil.to_s
      p.seoerrors.create(code:NO_HREF, line:a.line, desc:a.content.to_s.force_encoding("utf-8")[0..254], page_id:p.id, site_id:p.site_id)
      next
    end
    begin
      dst = URI.parse(a['href'].to_s)
    rescue
      p.seoerrors.create(code:BAD_LINK, line:a.line, desc:a["href"].to_s.force_encoding("utf-8")[0..254], page_id:p.id, site_id:p.site_id)
      next
    end
    if (!(a["href"].start_with? "./") && !(dst.to_s.include? hst.to_s) && !(dst.host.nil?)) && (!a["rel"] || !a["rel"].include?("nofollow"))
      p.seoerrors.create(code:EXTERNAL_FOLLOW, line:a.line, desc:a["href"].to_s.force_encoding("utf-8")[0..254], page_id:p.id, site_id:p.site_id)
    end
  end
  # Images
  tmp = []
  doc.css("img").each do |i|
    if i[:src].nil?
      next
    end
    u = site.url
    u = u[0..-2] if u[-1] == '/'
    i[:src] = u + i[:src][1..-1] if i[:src].to_s.start_with?("./")
    #p.imgs.create(url:i[:src], title:i[:title], alt:i[:alt], page_id:p.id)
    if i[:src].end_with?(".jpeg") || i[:src].end_with?(".jpg")
      begin
              iData = open(i[:src])
              dt = EXIFR::JPEG.new(iData).image_description.force_encoding("utf-8")
      rescue
        dt = nil
      end
      tmp.append({:loc => i[:src].force_encoding("utf-8"), :title => i[:alt].force_encoding("utf-8"), :caption => dt})
      p.seoerrors.create(code:IMG_NOALT, line:i[:line], desc:i.to_s.force_encoding("utf-8"), page_id:p.id, site_id:p.site.id) unless (i[:alt] != nil)
    end
  end
        $images << tmp
        p.save
end

# Main
mArgv = ARGV
if mArgv[0].nil?
  Site.all.each { |s| mArgv.append(s.url)}
end
mArgv.each do |url|
  datas = []
  url = 'http://' + url unless url.start_with?('http://') || url.start_with?('https://')
  if (site = Site.find_by(url:url)) == nil
    site = Site.create
  end
  site.url = url
  SitemapGenerator::Sitemap.default_host = url
  SitemapGenerator::Sitemap.filename = Time.now.to_i
  SitemapGenerator::Sitemap.compress = false
  site.name = url if site.name.nil?
  if !site || !site.url
    return
  end
  pages = []
  $images = []
  $httpErrors = []
  puts "Crawling #{site.url}"
  crawlPb = ProgressBar.create(:total => nil,
                               :format         => '%a %bC%i %p%% %t',
                               :progress_mark  => ' ',
                               :remainder_mark => 'o')
  Anemone.crawl(site.url, :threads => 8, :verbose => false, :obey_robots_txt => true) do |anemone|
    anemone.on_every_page do |page|
      if page.code.to_i == 404
        httpErrors << page.url
      end
      if page.html? && page.code.to_i == 200 && page.url.to_s != site.url
        crawlPb.increment
        pages << page.url
        datas << page
      end #ahah
    end
  end
  crawlPb.refresh
  crawlPb.stop
  puts "Crawl over on #{pages.size} pages. Filling database."
  pb = ProgressBar.create(:total    => datas.count,
                          :format         => '%a %bC%i %p%% %t',
                          :progress_mark  => ' ',
                          :remainder_mark => 'o')
  datas.each do |d|
    runPage(d, site)
    pb.increment
  end
  pb.refresh
  pb.finish
  #dupCheck = site.hxes.detect {|e| site.hxes.count {|c| c.content.to_s == e.content.to_s } > 1}
  #  site.titles.each { |title| dupCheck += site.titles.select {|t| site.titles.count {|c| c.content.to_s == title.content.to_s} > 1} }
  #dupCheck = site.titles.all.uniq!
  #  dupCheck.each { |e| e.page.seoerrors.create(code:TITLE_DUPLICATE, line: e[:line], page_id: e.page.id, site_id: e.page.site.id, desc: e.content.force_encoding("utf-8"))}   
  #dupCheck = []
  #site.hxes.each { |hx| dupCheck += site.hxes.select { |c|site.hxes.count {|c| c.content.to_s == hx.content.to_s} > 1} }
  dupCheck = site.hxes - site.hxes.uniq! {|l| l.content}
  dupCheck.each { |e| e.page.seoerrors.create(code:HX_DUPLICATE, line: e[:line], page_id: e.page.id, site_id: e.page.site.id, desc: "[ Duplique ] " + e.content.to_s.force_encoding("utf-8"))}
  puts 'Generating Sitemap'
  SitemapGenerator::Sitemap.create do
    pages.each do |p|
      add p.path.to_s.force_encoding("utf-8"), :changefreq => 'daily', :priority => 0.5, :images => $images.shift
    end
  end
  site.sitemap.delete unless site.sitemap.nil?
  site.sitemap = Sitemap.create(str:SitemapGenerator::Sitemap.filename.to_s + ".xml", site_id:site.id)
  site.save
end
puts "Done."
open((Dir.pwd + "/public/" + SitemapGenerator::Sitemap.filename.to_s + ".xml"), 'r') {|f| @fData = f.read}
open((Dir.pwd + "/public/" + SitemapGenerator::Sitemap.filename.to_s + ".xml"), 'w') {|f| f.write @fData.gsub! "\n", ''}
exit(0)
