require 'telegram/bot'
require_relative 'tokens'
require_relative 'weather_methods'
require_relative 'bot_state'

class WeatherBot
  include WeatherMethods
  include BotState

  def initialize
    tokens = Tokens.new
    @current_state = BotState::LISTENING

    Telegram::Bot::Client.run(tokens.telegram_token) do |bot|
      bot.listen do |message|
        case message
        when Telegram::Bot::Types::CallbackQuery

          # bot.api.send_message(chat_id: message.from.id, text: message.data)
          coordinates = get_coordinates_for_selected_city(bot, message, message.data)
          units = 'metric'
          lang = 'en'
          weather_forecast = get_weather_using_coordinates(coordinates, units, lang, tokens.ow_token)
          send_forecast_for_received_city_coordinates(bot, message, weather_forecast)

          create_log(message, 'City Search', message.data)
          @current_state = BotState::LISTENING
          send_available_commands(bot, message)

        when Telegram::Bot::Types::Message
          case message.text
          when '/start'
            send_instructions(bot, message)
            @current_state = BotState::LISTENING

          when '/stop'
            stop_bot(bot, message)

          when '/weather'

            ask_for_city_or_gps_location(bot, message)
            @current_state = BotState::AWAITING_USER_RESPONSE

          when '/mylocation'

            ask_user_for_gps_location(bot, message)
            @current_state = BotState::AWAITING_GPS_COORDINATES

          when '/echo'

            send_echo(bot, message)

          else

            if awaiting_response?

              @current_state = BotState::AWAITING_CITY_SELECTION if send_back_cities_list(bot, message)

            elsif !message.location.nil? && awaiting_coordinates?

              coordinates = get_coordinates_from_message(message)
              units = 'metric'
              lang = 'en'
              weather_forecast = get_weather_using_coordinates(coordinates, units, lang, tokens.ow_token)
              send_forecast_for_received_coordinates(bot, message, weather_forecast)

              create_log(message, 'GPS Search', coordinates)

              @current_state = BotState::LISTENING
              send_available_commands(bot, message)

            else send_invalid_text_response(bot, message)
            end
          end
        end
      end
    end
  end
end
