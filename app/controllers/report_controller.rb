
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
end