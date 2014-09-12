require 'rubygems'
require 'active_record'
require 'yaml'
require 'sqlite3'
 
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite",
  :database  => 'C:\Users\Informatique\Desktop\SEO\SEO\db\development.sqlite3'
)

#dbconfig = YAML::load(File.open('config\database.yml'))
#puts dbconfig
#ActiveRecord::Base.establish_connection(dbconfig)

# Define your classes based on the database, as always
class Site < ActiveRecord::Base
end

puts Site.all
Site.create
puts Site.all