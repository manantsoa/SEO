def parseHx()
	@err[:hx] = []
	@err[:html] = []
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
					:file => p.url,
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
	def show
		@err = {}
		if (@site = Site.find(params[:id])) == nil
			redirect_to root_path
		end
		parseHx()
	end
	def index
		@sites = Site.all
	end
end