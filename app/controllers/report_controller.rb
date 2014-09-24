
class ReportController < ApplicationController
	before_filter :load

	def bypage
		p = Site.find(params[:id]).pages.all.where(id:params[:pid]).first
		@Page = Site.find(params[:id]).pages.all.where(id:params[:pid]).all
		@Site = Site.find(params[:id])
		if p.hxes.first.nil?
			return
		end
	end
	def load
	end
	def show
		if (@site = Site.find(params[:id])) == nil
			redirect_to root_path
		end
	end
	def hx		
		if (@site = Site.find(params[:id])) == nil
			redirect_to root_path
		end
	end
	def img
	end
	def test
		# Juste parce qu'on aime coder moche <3
		# Owi !!!
	end
	def index
		@sites = Site.all
	end
	def destroy
		Site.find(params[:id]).destroy
		redirect_to report_index_path
	end
end