require_relative '../lib/weather_methods'
require_relative '../lib/weather_text_bool_methods'
require 'net/http'
require 'json'
require 'open-uri'
require_relative '../lib/logger'
require_relative '../lib/cities'
require_relative '../lib/bot_state'

describe WeatherMethods do
  include WeatherMethods
  let(:current_state) { BotState::RETRIEVING_SEARCH_RESULTS }

  context 'retrieving_search_results? checks if the bot is in a specific state' do
    it 'will return a boolean value' do
      expect(retrieving_search_results?).to be(true).or be(false)
    end
  end

  context 'icon_url(icon_name) will create a hiperlink to an icon' do
    it 'will return a string with the hyperlink' do
      expect(icon_url('hyperlink')).to be_instance_of(String)
    end
  end
end
