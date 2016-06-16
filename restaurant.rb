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
