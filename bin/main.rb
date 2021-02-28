#!/usr/bin/env ruby
require_relative '../lib/weather_bot'
require_relative '../lib/bot_state'



  bot = WeatherBot.new

  current_state = BotState::LISTENING
  list_sent = false
  bot.start_bot(current_state, list_sent)
