require_relative '../lib/cities'
require 'json'
require 'active_support/inflector'

describe Cities do
  let(:city_hash) { Cities.new }
  let(:city_name) { 'Salta' }
  let(:city_country) { 'AR' }
  let(:aux_hash) { city_hash.get_city_coordinates(city_name, city_country) }

  context ' creates a filtered hash ' do
    it 'get_cities_list(city_name) will return a non empty hash for this test values' do
      expect(city_hash.get_cities_list(city_name)).not_to be_empty
    end
    it 'get_city_coordinates(city_name, city_country) will return a 2 items hash' do
      expect(aux_hash.count).to be 2
    end
  end
end
