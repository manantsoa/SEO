def parseHx()
	@err[:hx] = []
	if @site.nil?
		return nil
	end
	@site.pages.each do |p|
		if p.hxes.first.nil?
			next
		end
		orderBool = false;
		prv = p.hxes.first.x
		max = prv
		p.hxes.each do |h|
			if (h.x - prv).abs > 1 
				@err[:hx].append({
					:curr => h,
					:file => p,
					:type => ERR_HX_DIFF
					})
			end
			if (h.x < max) and !orderBool
				@err[:hx].append({
					:curr => h,
					:file => p,
					:type => ERR_HX_ORDER
					})
				orderBool = true
			end
			prv = h.x
		end
	end
end

class ReportController < ApplicationController
	before_filter :load

	def bypage
		@err = {}
		@err[:hx] = []
		p = Site.find(params[:id]).pages.all.where(id:params[:pid]).first
		@Page = Site.find(params[:id]).pages.all.where(id:params[:pid]).all
		if p.hxes.first.nil?
			return
		end
		@err[:hx].append("Pas d'erreurs de balises")
#		orderBool = false;
		prv = p.hxes.first.x
		p.hxes.each do |h|
			if (h.x - prv).abs > 1 
				@err[:hx].append({
					:curr => h,
					:file => p,
					:type => ERR_HX_DIFF
					})
			end
		end
	end
	def load

	end
	def show
		@err = {}
		if (@site = Site.find(params[:id])) == nil
			redirect_to root_path
		end
		parseHx()
	end
	def hx		
		@err = {}
		if (@site = Site.find(params[:id])) == nil
			redirect_to root_path
		end
		parseHx()
		@hxFiles = []
		@err[:hx].each {|h| @hxFiles << h[:file].id}
	end
	def img
	end
	def test
		# Juste parce qu'on aime coder moche <3
		# Owi !!!
	end
	def index
		@err = {}
		@sites = Site.all
		parseHx()
	end
end