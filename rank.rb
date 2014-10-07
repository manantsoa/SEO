require 'google-search'
require 'rubygems'
require (`uname` == "Linux\n" ? 'mysql' : 'pg')
require 'yaml'
require 'active_record'
require 'openssl'
require 'htmlentities'
require 'nokogiri'

DEPTH = 10
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
y = YAML.load_file('./config/database.yml')["development"]
ActiveRecord::Base.establish_connection(y)

class Site < ActiveRecord::Base
	has_many :queries, :dependent => :destroy
end

class Position < ActiveRecord::Base
	belongs_to :query
end

class Query < ActiveRecord::Base
	belongs_to :site
	has_many :positions, :dependent => :destroy
end

def searchFor(searchs, site)
	res = Hash.new
	searchs.each do |search|
		puts search
		search.gsub! ' ', '+'
		site = URI.parse(site) unless site.kind_of?(URI::HTTP)
		catch (:done) do 
		DEPTH.times do |pageId|
			query  = "http://www.google.fr/search?q=#{search}&hl=fr&ie=UTF-8&oq=#{search}&lr=lang_fr&cr=countryFR&es_sm=93&start=#{10 * pageId}&aqs=chrome.1.69i57j0l5.3837j0j7"
			begin
				resp = Nokogiri::HTML(open(query, 
										   "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36").read)
			rescue Exception => e
				resp = Nokogiri::HTML("<html></html>")
				puts "Error on google query #{e.to_s}"
				exit(0)
			end
			title_tab = []
			resp.css(".r").each { |x|  title_tab << x.children}
			title_tab = title_tab.sort_by {|a| resp.to_s.index(a.to_s)}
			title_tab.size.times do |linkId|
				if title_tab[linkId].to_s.include? site.host
					res[search.gsub '+', ' '] = 10 * pageId + linkId + 1
					throw :done
				end
			end
		end
		end
	end
	return res
end

def googlePos(url, keyw)
	res = []
	url = 'http://' + url unless url.start_with?('http://') || url.start_with?('https://')
	url = URI.parse(url)
	coder = HTMLEntities.new

	keyw.each do |k|
		qRes = [k, 10000, nil]
		puts "Searching for #{k}"
		Google::Search::Web.new(:query => k, :language => :fr, :gl => 'FR').each_with_index do |q, i|
			if URI.parse(coder.decode(q.uri)).host.include? url.host
				puts "Query : #{k} | Position : #{i + 1}"
				qRes[1] = (i + 1)
				qRes[2] = q.uri
				res << qRes
				break
			end
		end
	end
	return res
end

keyw = []
(1..ARGV.size - 1).each {|s| keyw << (ARGV[s].dup)}
#puts keyw
#puts ARGV[0]
begin
	site = Site.find(ARGV[0].to_i)
rescue
	exit(0)
end
googlePos(site.url, keyw).each do |key, value, url|
	puts "#{key} #{value} #{url}"
	begin
		q = site.queries.where(query:key).first!
	rescue
		q = site.queries.create(query:key, site_id:ARGV[0].to_i)
	end
	q.positions.create(pos:value, url:url)
end
print "done"