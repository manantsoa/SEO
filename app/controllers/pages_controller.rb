class PagesController < ApplicationController
  def configCrawler
  end
  def hxReport
  end
  def index
 	@sites = Site.all
  end
end
