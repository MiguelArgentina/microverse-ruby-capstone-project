require 'json'
require 'active_support/inflector'

# :nodoc:
class Cities
  def initialize
    @all_cities_hash = File.read('./assets/json-lists/city.list.min.json')
    @all_countries_hash = File.read('./assets/json-lists/ISO3166.country.list.json')
  end

  def get_country_name_list(country)
    countries_hash = JSON.parse(@all_countries_hash)
    countries = []
    countries_hash.each do |item|
      if ActiveSupport::Inflector.transliterate(item['name']).downcase.include?\
        (ActiveSupport::Inflector.transliterate(country).downcase)
        countries.push(item['alpha-2'])
      end
    end
    countries
  end

  def get_cities_list(city_name)
    cities_hash = JSON.parse(@all_cities_hash)
    cities_hash.select do |item|
      ActiveSupport::Inflector.transliterate(item['name']).downcase.include?\
        (ActiveSupport::Inflector.transliterate(city_name).downcase)
    end
  end

  def get_cities_list_filter_country(city_name, country)
    cities_hash = JSON.parse(@all_cities_hash)
    result = []
    country_list = []
    country.each do |country_item|
      result = cities_hash.select do |item|
        (ActiveSupport::Inflector.transliterate(item['name']).downcase.include? \
          ActiveSupport::Inflector.transliterate(city_name).downcase) && (\
          ActiveSupport::Inflector.transliterate(item['country']).downcase.include? \
            ActiveSupport::Inflector.transliterate(country_item).downcase)
      end
      country_list += result
    end
    country_list
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
