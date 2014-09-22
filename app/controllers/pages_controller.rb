require 'open-uri'

class PagesController < ApplicationController
  def configCrawler
  end
  def submitCrawl
    url = URI.parse(params[:site][:url])
  	Site.create(name:params[:site][:name], url:url.to_s)
    
      exec("ruby crawler.rb \"" + url.to_s + "\"")
    
  	redirect_to root_path
  end
  def hxReport
  end

  def index
 	  @sites = Site.all
  end
end
