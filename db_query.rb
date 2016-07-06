require_relative 'restaurant'


def db_query(num)
  duplicates = Restaurant.select(:name,:ratings).group(:country,:ratings, :name).having("count(*) > 1").all
  duplicates.each do |restaurant|
    cache = Restaurant.where(name: restaurant.name).where(ratings: restaurant.ratings).first
    Restaurant.where(name: restaurant.name).where(ratings: restaurant.ratings).destroy_all
    Restaurant.create(
    name: cache.name,
    country: cache.country,
    city: cache.city,
    ratings: cache.ratings,
    score: cache.score,
    total_ratings: cache.total_ratings
    )
  end
  Restaurant.all.order(score: :desc).first(num).each do |restaurant|
    puts restaurant.name
  end
end


#Hos Thea
# Efendi Tea & Coffee House
# Valentin
# 1877
# Hav - Fisk & Skalldyr AS
# Riso mat & kaffebar
# Himalaya Tandori Indian Restaurant
# Graziella
# Statholdergaarden
# Zenzi by Realmat

# La Montgolfiere Henri Geraci
# Le Louis XV - Alain Ducasse a l'Hotel de Paris
# Restaurant Joel Robuchon Monte-Carlo
# Blue Bay
# Graziella
# Maya Bay
# Avenue 31
# Le Vistamar
# Il Terrazzino
# Restaurant Yoshi
# Monaco Beefbar
# Huit et Demi
# Valentin
# Quai des Artistes
# Nobu Fairmont Monte-Carlo
# l'Horizon Deck
# Lo Sfizio
# Mozza
# La Saliere
# La Note Bleue
