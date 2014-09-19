def parseHx()
	@err[:hx] = []
	if @site.nil?
		return nil
	end
	@site.pages.each do |p|
		if p.hxes.first.nil?
			next
		end
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
#			if (h.x > first) and not orderBool
#				@err[:hx].append({
#					:curr => h,
#					:file => p.url,
#					:type => ERR_HX_ORDER
#					})
#				orderBool = true
#			end
			prv = h.x
		end
	end
end

class ReportController < ApplicationController
	before_filter :load

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
	end
	def index
		@sites = Site.all
	end
end