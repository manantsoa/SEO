
class ReportController < ApplicationController
	def bypage
#		p = Site.find(params[:id]).pages.all.where(id:params[:pid]).first
		@Page = Site.find(params[:id]).pages.all.where(id:params[:pid]).all
		@Site = Site.find(params[:id])
	end
	def initialize
		super
		@HX_ORDER = 1                        # Erreur d'ordonancement
		@HX_DUPLICATE = 2                    # Duplicatat de balise <hx> sut le site
		@HX_DIFF = 3                         # </h1> <h3> 
		@PARSER = 4                        	 # Erreur de Nokogiri
		@TITLE_DUPLICATE = 5				 # Duplicatat de titre
		@IMG_NOALT = 6						 # Pas de alt sur une image
		@TITLE_LENGTH = 7          			 # Titre trop long
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
	def index
		@sites = Site.all
	end
	def destroy
		Site.find(params[:id]).destroy
		redirect_to report_index_path
	end
end