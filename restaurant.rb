require 'active_record'
require 'mini_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'restaurant.sqlite3')

class Restaurant < ActiveRecord::Base
  field :name, as: :string
  field :city, as: :string
  field :total_ratings, as: :integer
  field :ratings, as: :string
end

Restaurant.auto_upgrade!

Restaurant.all.each do |restaurant|
  puts restaurant['name']
  puts restaurant['city']
  puts restaurant['total_ratings']
  puts restaurant['ratings']
  puts "\n\n"
end
