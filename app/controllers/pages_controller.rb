class PagesController < ApplicationController
  def configCrawler
	def new
		@url = Site.new
  	end
  end
  def submitCrawl
  	Site.create(name:params[:name], url:params[:url])
  	redirect_to root_path
  end
  def hxReport
  end

  def index
 	  @sites = Site.all
  end
end
