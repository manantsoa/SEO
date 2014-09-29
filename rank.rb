# This > all > SEO Soft :)

require 'open-uri'
require 'nokogiri'
require 'rubygems'
require (`uname` == "Linux\n" ? 'mysql' : 'pg')
require 'yaml'
require 'active_record'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
y = YAML.load_file('./config/database.yml')["development"]
ActiveRecord::Base.establish_connection(y)

class Site < ActiveRecord::Base
	has_many :positions, :dependent => :destroy
end

class Position < ActiveRecord::Base
	belongs_to :site
end

def posInPage(host, raw)
	pos = 0
	begin
		fmt = Nokogiri(raw)
	rescue Exception => e
		puts e.to_s
		return pos
	end
	orderFmt = fmt.css("h3").sort_by {|t| t.line}
	orderFmt.each do |bal|
		pos += 1 unless bal.to_s.include? "google"
		#puts "=========================== #{pos}"
		#puts bal
		return pos if bal.to_s.include? host
	end
	puts "Root not found in h3. (Should never happen)"
	return (0)
end

def googlePos(url, keywords, depth = 10, verbose = true)
	url = 'http://' + url.to_s unless url.to_s.start_with?('http://') || url.to_s.start_with?('https://')
	url = URI(url) unless url.kind_of? URI::HTTP 
	keywords = [keywords] unless keywords.is_a? Array
	ret = Hash.new

	puts url.to_s
	return if url.host.nil?
	puts "Recherche de #{url}" if verbose
	keywords.each do |keyword|
		puts "\t=> #{keyword}" if verbose
		keyword.gsub! ' ', '+'
		ret[keyword] = 0
		depth.times do |pageNum|
			puts "\t   Page #{pageNum + 1}" if verbose
			query = "https://www.google.fr/search?q=#{keyword}&start=#{10 * pageNum}"
			begin
				resp = open(query).read
			rescue Exception => e
				puts e.to_s
				resp = "<html></html>"
			end
			if resp.include? url.host
				ret[keyword] = 10 * pageNum + posInPage(url.host, resp) 
				break
			end		
		end
	end
	return ret
end
puts ARGV
keyw = []
(1..ARGV.size - 1).each {|s| keyw.append(ARGV[s].dup)}
#puts keyw
#puts ARGV[0]
begin
	site = Site.find(ARGV[0].to_i)
rescue nil
end
googlePos(site.url, keyw).each do |key, value| 
	begin
		r = site.positions.where(query:key).first
		r.pos = value
		r.save!
	rescue
		r = site.positions.create(query:key, pos:value)
	end
end