require 'net/http'
require 'json'
require 'open-uri'
require_relative 'cities'
require_relative 'logger'
require_relative 'weather_text_bool_methods'

module WeatherMethods
  include Alogger
  include WeatherTextBoolMethods

  def send_instructions(bot, message)
    bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name} ,
    welcome to Weather bot created by @TucuGomez.
    This bot will give you weather forecast for
    you current location, or a desired one.
    Use  /start to start the bot, /echo to test
    if the bot is active, /mylocation to get weather
      forecast for your location, /weather to get weather
       for any city you prefer and  /stop to end the bot")
  end

  def ask_for_city_or_gps_location(bot, message)
    bot.api.send_message(chat_id: message.chat.id,
                         text: 'Send me the first letters of the
                         location you want the weather forecast for,
                         or hit /mylocation to use your current location',
                         date: message.date)
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
                                          "_#{message.from.first_name}"
                                        else
                                          message.from.username
                                        end}! This is a test method to check if the bot is running.
                                        Echo @ #{Time.at(message.date.to_i).to_datetime}!", date: message.date)
  end

  def get_weather_using_coordinates(coordinates, units, token, lang)
    uri = URI('http://api.openweathermap.org/data/2.5/weather?')
    params = { lat: coordinates[:lat], lon: coordinates[:lon], units: units, lang: lang, appid: token }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)

    json_object = nil
    json_object = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)

    return json_object unless json_object.nil?

    { 'error_message' => 'An error gas occured while obtaining the forecast. Please try again' }
  end

  def send_back_cities_list(bot, message)
    cities_list = Cities.new.get_cities_list(message.text)
    case cities_list.size
    when 0
      bot.api.send_message(chat_id: message.chat.id,
                           text: 'The search didn´t return any result. Please enter a new name')
      false
    when 20..Float::INFINITY
      bot.api.send_message(chat_id: message.chat.id,
                           text: 'The search returned more than 20 results. Please enter a new name')
      false
    else
      kb = create_keyboard(cities_list)
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      bot.api.send_message(chat_id: message.chat.id, text: 'Select the city:', reply_markup: markup)
      true
    end
  end

  def create_keyboard(cities_list)
    kb = []
    kb_row = []
    cities_list.each_with_index do |city, index|
      kb_row << Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{city['name']}, #{city['country']}",
                                                               callback_data: "#{city['name']},#{city['country']}")
      if index.even?
        kb << kb_row
        kb_row = []
      end
    end
    kb
  end

  def get_coordinates_for_selected_city(_bot, _message, message_need_split)
    selected_city = message_need_split.split(',')[0]
    selected_country = message_need_split.split(',')[1]
    Cities.new.get_city_coordinates(selected_city, selected_country)
  end

  def get_coordinates_from_message(message)
    { lat: message.location.latitude, lon: message.location.longitude }
  end

  def send_forecast_for_received_coordinates(bot, message, weather_forecast)
    markup = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    bot.api.sendPhoto(chat_id: message.chat.id,
                      photo: icon_url(weather_forecast['weather'][0]['icon']),
                      caption: get_coord_caption(weather_forecast),
                      reply_markup: markup)
  end

  def forecast_for_coordinates(bot, message, weather_forecast)
    markup = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    bot.api.sendPhoto(chat_id: message.from.id,
                      photo: icon_url(weather_forecast['weather'][0]['icon']),
                      caption: get_city_caption(weather_forecast),
                      reply_markup: markup)
  end
end
