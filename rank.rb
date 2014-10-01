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
	has_many :queries, :dependent => :destroy

end

class Position < ActiveRecord::Base
	belongs_to :query
end

class Query < ActiveRecord::Base
	belongs_to :site
	has_many :positions, :dependent => :destroy
end

def googlePos(url, keyw)
	res = Hash.new
	url = 'http://' + url unless url.start_with?('http://') || url.start_with?('https://')
	url = URI.parse(url)
	coder = HTMLEntities.new

	keyw.each do |k|
		res[k] = -1
		puts "Searching for #{k}"
		Google::Search::Web.new(:query => k, :language => :fr, :gl => 'FR').each_with_index do |q, i|
			#puts "#{q.visible_uri} | #{q.index}"
			if URI.parse(coder.decode(q.uri)).host.include? url.host
				puts "Query : #{k} | Position : #{i + 1}"
				res[k] = (i + 1)
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
		q = site.queries.where(query:key).first!
	rescue
		q = site.queries.create(query:key, site_id:ARGV[0].to_i)
	end
	q.positions.create(pos:value)
end