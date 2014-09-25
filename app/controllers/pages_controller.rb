require 'open-uri'

class PagesController < ApplicationController
  def configCrawler
  end
  def submitCrawl
    url = URI.parse(params[:site][:url])
  	Site.create(name:params[:site][:name], url:url.to_s) unless Site.where(url:url.to_s).count > 0
    spawn("ruby crawler.rb \"" + url.to_s + "\"")
  	redirect_to root_path
  end
  def hxReport
  end
  def recrawl
    site = Site.find(params[:id])
    #Site.create(name:site.name, url:site.url.to_s) unless Site.where(url:url.to_s).count > 0
    spawn("ruby crawler.rb \"" + site.url.to_s + "\"")
    redirect_to root_path
  end
  def index
 	  @sites = Site.all
  end
end
