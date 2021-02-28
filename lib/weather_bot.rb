# rubocop: disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/BlockLength, Metrics/PerceivedComplexity
require 'telegram/bot'
require_relative 'tokens'
require_relative 'weather_methods'
require_relative 'weather_text_bool_methods'
require_relative 'bot_state'

# :nodoc:
class WeatherBot
  include WeatherMethods
  include WeatherTextBoolMethods
  include BotState

  def initialize
    tokens = Tokens.new

  end

  def start_bot(current_state, list_sent)
    start_listening(current_state, list_sent)
  end

  private

  def start_listening(current_state, list_sent)
    tokens = Tokens.new

    Telegram::Bot::Client.run(tokens.get_token(:telegram)) do |bot|
      bot.listen do |message|
        case message
        when Telegram::Bot::Types::CallbackQuery

          # bot.api.send_message(chat_id: message.from.id, text: message.data)
          coordinates = get_coordinates_for_selected_city(bot, message, message.data)
          units = 'metric'
          lang = 'en'
          weather_forecast = get_weather_using_coordinates(coordinates, units, tokens.get_token(:ow), lang)
          forecast_for_coordinates(bot, message, weather_forecast)

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

              list_sent = send_back_cities_list(bot, message)

            elsif list_sent
              @current_state = BotState::AWAITING_CITY_SELECTION
              list_sent = false

            elsif !message.location.nil? && awaiting_coordinates?

              coordinates = get_coordinates_from_message(message)
              units = 'metric'
              lang = 'en'
              weather_forecast = get_weather_using_coordinates(coordinates, units, tokens.get_token(:ow), lang)
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
# rubocop: enable Metrics/CyclomaticComplexity, Metrics/BlockLength, Metrics/MethodLength, Metrics/PerceivedComplexity
