require 'json'
require 'active_support/inflector'

# :nodoc:
class Cities
  def initialize
    @all_cities_hash = File.read('./assets/json-lists/city.list.min.json')
  end

  def get_cities_list(city_name)
    cities_hash = JSON.parse(@all_cities_hash)
    cities_hash.select do |item|
      ActiveSupport::Inflector.transliterate(item['name']).include? ActiveSupport::Inflector.transliterate(city_name)
    end
  end

  def get_city_coordinates(city_name, city_country)
    cities_hash = JSON.parse(@all_cities_hash)
    city = cities_hash.select do |item|
      ActiveSupport::Inflector.transliterate(item['name']) ==
        ActiveSupport::Inflector.transliterate(city_name) && item['country'] == city_country
    end
    { lat: city[0]['coord']['lat'], lon: city[0]['coord']['lon'] }
  end
end
