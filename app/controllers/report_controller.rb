def parseHx()
	@hxErr = {}
	@hxErr[:curr] = []
	@hxErr[:file]   = []
	if @site.nil?
		return nil
	end
	@site.pages.each do |p|
		if p.hxes.first.nil?
			next
		end
		prv = p.hxes.first.x
		p.hxes.each do |h|
			if (h.x - prv).abs > 1 
				@hxErr[:file].append(p.url)
				@hxErr[:curr].append(h)
			end
			prv = h.x
		end
	end
end




class ReportController < ApplicationController
	def show
		if (@site = Site.find(params[:id])) == nil
			redirect_to root_path
		end
		parseHx()
	end
end