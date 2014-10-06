require 'csv'

class ReportController < ApplicationController
	def bypage
#		p = Site.find(params[:id]).pages.all.where(id:params[:pid]).first
		@Page = Site.find(params[:id]).pages.all.where(id:params[:pid]).all
		@Site = Site.find(params[:id])
	end
	def initialize
		super
		@HX_ORDER 			= 1              # Erreur d'ordonancement
		@HX_DUPLICATE 		= 2              # Duplicatat de balise <hx> sut le site
		@HX_DIFF 			= 3              # </h1> <h3> 
		@PARSER 			= 4            	 # Erreur de Nokogiri
		@TITLE_DUPLICATE 	= 5				 # Duplicatat de titre
		@IMG_NOALT 			= 6				 # Pas de alt sur une image
		@TITLE_LENGTH 		= 7 			 # Titre trop long
		@EXTERNAL_FOLLOW    = 8		         # Lien externe sans nofollow
		@NO_HREF            = 9     	     # balise <a> sans href
		@BAD_LINK           = 10         	 # Lien mal formé qui fait planter le parseur uri
	end
	def show
		begin	
			@site = Site.find(params[:id])
		rescue
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
	def ranks
		@site = Site.find(params[:id])
		@ranks = @site.queries
	end
	def ranks_add
		query = params[:q].chomp
		puts query
		id = params[:id]
		query.gsub! "\r\n", "\" \""
		spawn("ruby rank.rb " + id.to_s + " \"" + query.to_s + "\"")
		redirect_to :back
	end
	def ranks_destroy
		Query.find(params[:id]).destroy
		redirect_to :back
	end
	def index
		@sites = Site.all
	end
	def destroy
		Site.find(params[:id]).destroy
		redirect_to :back
	end
	#@Page = Site.find(params[:id]).pages.all.where(id:params[:pid]).all
	def ranks_textfile
		site = Site.find(params[:id])
		get_content = ""
		site.queries.each do |t|
			get_content = get_content + t.query + "\r\n"
		end
		k_name = "export_keyword_" + site.id.to_s
	  	send_data get_content,:type => 'text',:disposition => "attachment; filename=#{k_name}"
	end
	def ranks_update
		site = Site.find(params[:id])
		id = params[:id]
		update_content = ""
		site.queries.each do |t|
			update_content = update_content + " \"" + t.query + "\""
		end
		puts update_content
		puts id.to_s
		spawn("ruby rank.rb " + id.to_s + update_content)
		redirect_to :back
	end
	def ranks_csv
   		site = Site.find(params[:id])
  		keywords_csv = CSV.generate(:col_sep => "\t") do |csv|
  			csv << [site.url]
		    csv << ["Requete", "Rang", "Meilleur", "Date"]
		 	site.queries.each do |key|
		      csv << [key.query, key.positions.last.pos, key.positions.minimum(:pos), key.positions.last.updated_at.strftime("%Y-%m-%d")]
		    end
		  end
		   
		send_data keywords_csv, :type => 'text/xls', :filename => 'export.xls'
	end
	def chart
		@keyword = Site.find(params[:id]).queries.all.where(id:params[:pid]).first
		posi = []
		date = []
		@keyword.positions.each do |t| 
			posi.push(t.pos)
			date.push(t.created_at.to_time.strftime("%Y-%m-%d"))
		end
		@chart = LazyHighCharts::HighChart.new('graph') do |f|
			f.title(:text => "Positionnement")
			f.xAxis(:categories => date)
			f.series(:name => "Positions", :yAxis => 0, :data => posi)

			f.yAxis [
			{:title => {:text => "positions", :margin => 70} },
			]

			f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
			f.chart({:defaultSeriesType=>"line"})
		end
	end
end
