require 'net/http'
require 'json'
require 'open-uri'
require_relative 'logger'
require_relative 'cities'

module WeatherMethods
  def awaiting_response?
    @current_state == BotState::AWAITING_USER_RESPONSE
  end

  def awaiting_coordinates?
    @current_state == BotState::AWAITING_GPS_COORDINATES
  end

  def retrieving_search_results?
    @current_state == BotState::RETRIEVING_SEARCH_RESULTS
  end

  def awaiting_city_selection?
    @current_state == BotState::AWAITING_CITY_SELECTION
  end

  def send_instructions(bot, message)
    bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name} ,
    welcome to Weather bot created by @TucuGomez. This bot will give you weather forecast for you current location, or a desired one.
    Use  /start to start the bot, /echo to test if the bot is active, /mylocation to get weather forecast for your location, /weather to get weather for any city you prefer and  /stop to end the bot")
  end

  def ask_for_city_or_gps_location(bot, message)
    bot.api.send_message(chat_id: message.chat.id,
                         text: 'Send me the first letters of the location you want the weather forecast for, or hit /mylocation to use your current location', date: message.date)
  end

  def ask_user_for_gps_location(bot, message)
    kb_button = [Telegram::Bot::Types::KeyboardButton.new(text: 'Send my coordinates', resize_keyboard: true,
                                                          remove_keyboard: true, request_location: true)]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb_button)
    bot.api.send_message(chat_id: message.chat.id, text: 'Please send me your coordinates', reply_markup: markup)
  end

  def send_echo(bot, message)
    bot.api.send_message(chat_id: message.chat.id,
                         text: "Hello #{if message.from.username.nil?
                                          '_' + message.from.first_name + (message.from.last_name.nil? ? '' : ' ' + message.from.last_name)
                                        else
                                          message.from.username
                                        end}! This is a test method to check if the bot is running. Echo @ #{Time.at(message.date.to_i).to_datetime}!", date: message.date)
  end

  def get_weather_using_coordinates(coordinates, units = 'metric', lang = 'es', token)
    uri = URI('http://api.openweathermap.org/data/2.5/weather?')
    params = { lat: coordinates[:lat], lon: coordinates[:lon], units: units, lang: lang, appid: token }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    json_object = nil
    json_object = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess) # data => url

    return json_object unless json_object.nil?

    { 'error_message' => 'An error gas occured while obtaining the gif. Please try again' }
  end

  def send_back_cities_list(bot, message)
    markup = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    # bot.api.send_message(chat_id: message.chat.id, text: 'This is the cities list', date: message.date)
    cities_list = Cities.new.get_cities_list(message.text)
    case cities_list.size
    when 0
      bot.api.send_message(chat_id: message.chat.id,
                           text: 'The search didn´t return any result. Please enter a new name')
      false
    when 10..Float::INFINITY
      bot.api.send_message(chat_id: message.chat.id,
                           text: 'The search returned too many results. Please enter a new name')
      false
    else

      kb = []
      cities_list.each do |city|
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: city['name'] + ', ' + city['country'],
                                                             callback_data: city['name'] + ',' + city['country'])
      end

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      bot.api.send_message(chat_id: message.chat.id, text: 'Select the city:', reply_markup: markup)
    end
  end

  def get_coordinates_for_selected_city(_bot, _message, message_need_split)
    selected_city = message_need_split.split(',')[0]
    selected_country = message_need_split.split(',')[1]
    coordinates = Cities.new.get_city_coordinates(selected_city, selected_country)
  end

  def get_coordinates_from_message(message)
    { lat: message.location.latitude, lon: message.location.longitude }
  end

  def send_forecast_for_received_coordinates(bot, message, weather_forecast)
    markup = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    bot.api.sendPhoto(chat_id: message.chat.id, photo: icon_url(weather_forecast['weather'][0]['icon']),
                      caption: "The weather for #{weather_forecast['name']} is #{weather_forecast['weather'][0]['description'].capitalize}.  The current temperature is #{weather_forecast['main']['temp']}ºc but it feels like #{weather_forecast['main']['feels_like']}ºc ", reply_markup: markup)
  end

  def send_forecast_for_received_city_coordinates(bot, message, weather_forecast)
    markup = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    bot.api.sendPhoto(chat_id: message.from.id, photo: icon_url(weather_forecast['weather'][0]['icon']),
                      caption: "The weather for #{weather_forecast['name']} is #{weather_forecast['weather'][0]['description'].capitalize}.  The current temperature is #{weather_forecast['main']['temp']}ºc but it feels like #{weather_forecast['main']['feels_like']}ºc ", reply_markup: markup)
  end

  def icon_url(icon_name)
    photo_url_start = 'http://openweathermap.org/img/wn/'
    photo_url_ending = '@2x.png'
    weather_icon_full_url = photo_url_start + icon_name + photo_url_ending
  end

  def create_log(message, query_title, coordinates = nil)
    log_hash = {
      'username' => if message.from.username.nil?
                      '_' + message.from.first_name + (message.from.last_name.nil? ? '' : ' ' + message.from.last_name)
                    else
                      message.from.username
                    end, 'date_time' => Time.now, 'location' => coordinates
    }
    logfile = Alogger.new
    logfile.create_log(query_title, log_hash)
    puts log_hash
  end

  def send_invalid_text_response(bot, message)
    bot.api.send_message(chat_id: message.chat.id,
                         text: "Invalid command, #{message.from.first_name}. You can use  /echo, /start, /stop, /mylocation or /weather ")
  end

  def send_available_commands(bot, message)
    case message
    when Telegram::Bot::Types::CallbackQuery
      bot.api.send_message(chat_id: message.from.id,
                           text: 'If you want to make another query, the available commands are: /echo, /start, /stop, /mylocation or /weather ')
    when Telegram::Bot::Types::Message
      bot.api.send_message(chat_id: message.chat.id,
                           text: 'If you want to make another query, the available commands are: /echo, /start, /stop, /mylocation or /weather ')
    end
  end

  def stop_bot(bot, message)
    bot.api.send_message(chat_id: message.chat.id,
                         text: "See you #{message.from.first_name}! Come visit me soon!", date: message.date)
  end
end
