require 'open-uri'

class PagesController < ApplicationController
  def configCrawler
  end
  def submitCrawl
    url = URI.parse(params[:site][:url])
    Site.create(url:url.to_s) unless Site.where(url:url.to_s).count > 0
    spawn("ruby crawler.rb \"" + url.to_s + "\"")
    spawn("ruby crawler.rb -m \"" + url.to_s + "\"")
    spawn('python2 ' + Rails.root.to_s + '/https.py -i ' + Rails.root.to_s + '/public/')
  	redirect_to list_path
  end
  def hxReport
  end
  def recrawl
    site = Site.find(params[:id])
    #Site.create(name:site.name, url:site.url.to_s) unless Site.where(url:url.to_s).count > 0
    Signal.trap("CLD") {Process.wait}
    puts "Trying to locate sitemap for " + site.url.to_s
    if File.exist?(Rails.root.to_s + 'sitemaps/' + site.url.to_s)
      puts "Fetching site with sitemap"
      spawn("ruby crawler.rb " + Rails.root.to_s + 'sitemaps/' + site.url.to_s)
    else
      puts "Crawling site"
      spawn("ruby crawler.rb \"" + site.url.to_s + "\"")
    end
    spawn('python2 ' + Rails.root.to_s + '/https.py -i ' + Rails.root.to_s + '/public/')
    redirect_to list_path
  end
  def recrawl2
    site = Site.find(params[:id])
    Signal.trap("CLD") {Process.wait}
    spawn("ruby crawler.rb -m \"" + site.url.to_s + "\"")
    spawn('python2 ' + Rails.root.to_s + '/https.py -i ' + Rails.root.to_s + '/public/')
    redirect_to list_path
  end
  def index
 	  @sites = Site.all
  end
  def design
    @sites = Site.all
  end
end
