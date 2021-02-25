require 'telegram/bot'
require_relative 'tokens.rb'
require_relative 'weather_methods.rb'
require_relative 'logger.rb'


class WeatherBot
  include WeatherMethods
  def initialize
    tokens = Tokens.new

    Telegram::Bot::Client.run(tokens.telegram_token) do |bot|
      awaiting_weather_response = false
      awaiting_user_coordinates = false

      bot.listen do |message|
        case message.text
        when '/start'

          bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name} ,
          welcome to Weather bot created by @TucuGomez. This bot will give you weather forecast for you current location, or a desired one.
          Use  /start to start the bot, /echo to test if the bot is active, /mylocation to get weather forecast for your location, /weather to get weather for any city you prefer and  /stop to end the bot")

        when '/stop'

          bot.api.send_message(chat_id: message.chat.id,
                               text: "See you #{message.from.first_name}! Come visit me soon!", date: message.date)

        when '/weather'

          bot.api.send_message(chat_id: message.chat.id,
                               text: 'Send me the first letters of the location you want the weather forecast for, or hit /mylocation to use your current location', date: message.date)
          awaiting_weather_response = true

        when '/mylocation'

          kb_button = [Telegram::Bot::Types::KeyboardButton.new(text: 'Send my coordinates', resize_keyboard: true,
                                                                remove_keyboard: true, request_location: true)]
          markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb_button)
          bot.api.send_message(chat_id: message.chat.id, text: 'Please send me your coordinates', reply_markup: markup)
          awaiting_weather_response = false
          awaiting_user_coordinates = true

        when '/echo'
          bot.api.send_message(chat_id: message.chat.id,
                               text: "Hello #{if message.from.username.nil?
                                                '_' + message.from.first_name + (message.from.last_name.nil? ? '' : ' ' + message.from.last_name)
                                              else
                                                message.from.username
                                              end}! Echo @ #{Time.at(message.date.to_i).to_datetime}!", date: message.date)

        when '/weatherme'
          random_gif = Gifme.new.gif_url
          puts random_gif
          if random_gif.is_a?(Hash)
            bot.api.send_message(chat_id: message.chat.id, text: (random_gif['error_message']).to_s,
                                 date: message.date)
          end
          bot.api.sendAnimation(chat_id: message.chat.id, animation: random_gif)

          log_hash = {}
          log_hash = {
            'username' => if message.from.username.nil?
                            '_' + message.from.first_name + (message.from.last_name.nil? ? '' : ' ' + message.from.last_name)
                          else
                            message.from.username
                          end, 'date_time' => Time.at(message.date.to_i).to_datetime, 'gif_sent' => random_gif
          }
          logfile = Alogger.new
          logfile.create_log('New gifme', log_hash)

        else

          if awaiting_weather_response
            markup = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
            bot.api.send_message(chat_id: message.chat.id, text: 'Searching location', date: message.date)
            awaiting_weather_response = false

          elsif !message.location.nil? && awaiting_user_coordinates


            #get_weather(message.location) # TODO: this method
            coordinates = Hash.new
            coordinates = {:lat => message.location.latitude, :lon => message.location.longitude}
            puts coordinates
            units = 'metric'
            lang = 'es'
            weather_forecast =get_weather_using_coordinates(coordinates, units, lang, tokens.ow_token)

            markup = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
            bot.api.send_message(chat_id: message.chat.id, text: "The weather for #{weather_forecast['name']} is #{weather_forecast['weather'][0]['description'].capitalize()}.  The current temperature #{weather_forecast['main']['temp'].to_s}ºc but it feels like #{weather_forecast['main']['feels_like'].to_s}ºc ",
                                 reply_markup: markup)
            awaiting_user_coordinates = false

            log_hash = {}
            log_hash = {
              'username' => if message.from.username.nil?
                              '_' + message.from.first_name + (message.from.last_name.nil? ? '' : ' ' + message.from.last_name)
                            else
                              message.from.username
                            end, 'date_time' => Time.at(message.date.to_i).to_datetime, 'location' => coordinates
            }
            logfile = Alogger.new
            logfile.create_log('New query', log_hash)



          else bot.api.send_message(chat_id: message.chat.id,
                                    text: "Invalid command, #{message.from.first_name}. You can use  /echo, /start,  /stop, /mylocation or /weather ")
          end
        end
      end
    end
  end
end
