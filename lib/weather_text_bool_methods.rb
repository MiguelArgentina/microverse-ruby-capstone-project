require_relative 'logger'

module WeatherTextBoolMethods
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

  def icon_url(icon_name)
    photo_url_start = 'http://openweathermap.org/img/wn/'
    photo_url_ending = '@2x.png'
    photo_url_start + icon_name + photo_url_ending
  end

  def get_coord_caption(weather_forecast)
    caption_text = "The weather for #{weather_forecast['name']} is"
    caption_text.concat(" #{weather_forecast['weather'][0]['description'].capitalize}.")
    caption_text.concat(" The current temperature is #{weather_forecast['main']['temp']}ºc")
    caption_text.concat(" but it feels like #{weather_forecast['main']['feels_like']}ºc")
  end

  def get_city_caption(weather_forecast)
    caption_text = "The weather for #{weather_forecast['name']}"
    caption_text.concat(" is #{weather_forecast['weather'][0]['description'].capitalize}.")
    caption_text.concat(" The current temperature is #{weather_forecast['main']['temp']}ºc")
    caption_text.concat(" but it feels like #{weather_forecast['main']['feels_like']}ºc ")
  end

  def get_welcome_text(message)
    welcome_text = "Hello #{message.from.first_name}, "
    welcome_text.concat('welcome to Weather bot created by @TucuGomez. ')
    welcome_text.concat('This bot will give you the weather forecast for ')
    welcome_text.concat('your current location, or a desired one. ')
    welcome_text.concat('Use  /start to start the bot, /echo to test ')
    welcome_text.concat('if the bot is active, /mylocation to get weather ')
    welcome_text.concat('forecast for your location, /weather to get weather ')
    welcome_text.concat('for any city you prefer and  /stop to end the bot')
  end

  def text_for_city_or_gps_msg
    message_text = 'Send me the first letters of the '
    message_text.concat('location you want the weather forecast for, ')
    message_text.concat('or hit /mylocation to use your current location')
  end

  def send_invalid_text_response(bot, message)
    bot.api.send_message(chat_id: message.chat.id,
                         text: invalid_text(message))
  end

  def invalid_text(message)
    text = "Invalid command, #{message.from.first_name}."
    text.concat('You can use /echo, /start, /stop,')
    text.concat(' /mylocation or /weather ')
  end

  def send_available_commands(bot, message)
    case message
    when Telegram::Bot::Types::CallbackQuery
      bot.api.send_message(chat_id: message.from.id,
                           text: available_commands)
    when Telegram::Bot::Types::Message
      bot.api.send_message(chat_id: message.chat.id,
                           text: available_commands)
    end
  end

  def available_commands
    available_commands_text = 'If you want to make another query,'
    available_commands_text.concat(' the available commands are:')
    available_commands_text.concat('/echo, /start, /stop, /mylocation or /weather')
  end

  def stop_bot(bot, message)
    bot.api.send_message(chat_id: message.chat.id,
                         text: "See you #{message.from.first_name}! Come visit me soon!", date: message.date)
  end

  def create_log(message, query_title, coordinates = nil)
    log_hash = {
      'username' => if message.from.username.nil?
                      "_#{message.from.first_name}#{message.from.last_name.nil? ? '' : " #{message.from.last_name}"}"
                    else
                      message.from.username
                    end, 'date_time' => Time.now, 'location' => coordinates
    }
    logfile = Alogger.new
    logfile.log_creator_handler(:logger_create_log, query_title, log_hash)
    puts log_hash
  end
end
