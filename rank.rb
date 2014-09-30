require 'google-search'
require 'rubygems'
require (`uname` == "Linux\n" ? 'mysql' : 'pg')
require 'yaml'
require 'active_record'
require 'openssl'
require 'htmlentities'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
y = YAML.load_file('./config/database.yml')["development"]
ActiveRecord::Base.establish_connection(y)

class Site < ActiveRecord::Base
	has_many :positions, :dependent => :destroy
end

class Position < ActiveRecord::Base
	belongs_to :site
end

def googlePos(url, keyw)
	res = Hash.new
	url = 'http://' + url unless url.start_with?('http://') || url.start_with?('https://')
	url = URI.parse(url)
	coder = HTMLEntities.new

	keyw.each do |k|
		res[k] = -1
		puts "Searching for #{k}"
		Google::Search::Web.new(:query => k, :language => :fr).each_with_index do |q, i|
			puts q.inspect
			if URI.parse(coder.decode(q.visible_uri)).host.include? url.host
				puts "Query : #{k} | Position : #{i + 1}"
				res[k] = (i + 1) * q.page
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
googlePos(site.url, keyw).each do |key, value|
	begin
		r = site.positions.where(query:key).first!
		r.pos = value
		r.save!
	rescue
		r = site.positions.create(query:key, pos:value)
	end
end