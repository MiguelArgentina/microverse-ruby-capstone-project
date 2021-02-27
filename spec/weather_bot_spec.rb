require_relative '../lib/tokens'
require_relative '../lib/weather_methods'
require_relative '../lib/weather_text_bool_methods'
require_relative '../lib/bot_state'

class WeatherBot
  describe WeatherBot do
    include WeatherMethods
    include BotState

    context ' returns hash with the forecast' do
      it 'get_weather_using_coordinates will return a hash' do
        expect(get_weather_using_coordinates({ lat: 30, lon: 40 }, 'metric',
                                             Tokens.new.ow_token, 'en')).to be_a(Hash)
      end
      it 'the hash should have multiple items' do
        expect(get_weather_using_coordinates({ lat: 30, lon: 40 }, 'metric', 'en',
                                             Tokens.new.ow_token).count).not_to be < 1
      end
    end
  end
end
