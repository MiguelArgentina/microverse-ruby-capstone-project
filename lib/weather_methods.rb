require 'net/http'
require 'json'
require 'open-uri'

module WeatherMethods

  def get_weather_using_coordinates(coordinates, units = 'metric', lang = 'es', token)
      #api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&units=metric&lang=es&appid={API key}

      uri = URI('http://api.openweathermap.org/data/2.5/weather?')
      params = {:lat => coordinates[:lat], :lon => coordinates[:lon], :units => units, :lang => lang, :appid => token }
      uri.query = URI.encode_www_form(params)
      puts uri
      puts uri.query
      res = Net::HTTP.get_response(uri)
      json_object = nil
      json_object = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess) #data => url

      return json_object unless json_object == nil
      {'error_message' => 'An error gas occured while obtaining the gif. Please try again'}
  end
  # Temperature is available in Fahrenheit, Celsius and Kelvin units.
  # For temperature in Fahrenheit use units=imperial
  # For temperature in Celsius use units=metric
  # Temperature in Kelvin is used by default, no need to use units parameter in API call

  # How to get icon URL
  # For code 500 - light rain icon = "10d". See below a full list of codes
  # URL is http://openweathermap.org/img/wn/10d@2x.png

  # Multilingual support
  # You can use the lang parameter to get the output in your language.
  # Translation is applied for the city name and description fields.

  # Call current weather data for one location
  # By city name
  # You can call by city name or city name, state code and country code. Please note that searching by states available only for the USA locations.
  # api.openweathermap.org/data/2.5/weather?q={city name},{state code},{country code}&appid={API key}

  # By geographic coordinates
  # API call
  # api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&units=metric&lang=es&appid={API key}
  # http://api.openweathermap.org/data/2.5/weather?lat=-34.593601&lon=-58.384882&units=metric&lang=es&appid=be954449397e974aa0a025babc182cbe

end
