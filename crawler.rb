require 'rubygems'
# Base de donnés 
require 'sqlite3'
require 'active_record'
# HTTP Parser 
require 'nokogiri'
# Connexion au site
require 'open-uri'

#ActiveRecord::Base.establish_connection(
#  :adapter => "sqlite",
#  :database  => 'C:\Users\Informatique\Desktop\SEO\SEO\db\development.sqlite3'
#)

# Connexion en dur temporaire a l abase de donnés de dev

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :host     => "",
  :username => "",
  :password => "",
  :database => "./db/development.sqlite3"
)

# Define your classes based on the database, as always
class Site < ActiveRecord::Base
end

class Page < ActiveRecord::Base
end

root  = "www.assurance-cyclo-scooter.com"
nextUrls = ["http://www." + root]
doneUrls = []
errors = [
	:hrefMissing => 0,
	:URIParse    => 0
]
while nextUrls.count > 0 do
	begin
		url = URI.parse(nextUrls.pop)
	rescue
		errors[:URIParse] += 1
		puts "Error while parsing url"
		next
	end
	doneUrls.push(url)
	puts "Crawling page " + url.path
	begin
		file = open(url.to_s)
		page = Nokogiri::HTML(file)
		links = page.css("a")
		urlsLinks = []
		links.each do |l|
			if not l or not l['href']
				errors[:hrefMissing] += 1
				next
			end
			if l['href'][0..1] == "./"
				puts 'lolilol'
				urlsLinks.append(URI.parse("http://www." + root + l['href'][1..-1]))
			else
				urlsLinks.append(URI.parse(l['href']))
			end
		end
	rescue Exception=>e
		puts "Could not crawl " + url.path + " : " + e.to_s
	ensure
		file.close unless file.nil?
	end
	puts "Found " + links.length.to_s + " links ( " + (links.length - (urlsLinks & doneUrls).length).to_s + " new(s) )"
	(urlsLinks).each do |l|
		puts l.host + " versus " + root
		if l.host != root
			puts "external link : " + l.to_s
			next
		end
		nextUrls.append(l) unless doneUrls.include?(l)
	end
	urlsLinks = []
puts "End loop, arrays : " + nextUrls.to_s + "\n\n" + doneUrls.to_s
end