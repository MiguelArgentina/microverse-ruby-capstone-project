# :nodoc:
class Tokens
  def initialize; end

  def get_token(identifier)
    case identifier
    when :ow
      ow_token
    when :telegram
      telegram_token
    end
  end

  private

  def telegram_token
    'fill_telegram_token_here'
  end

  def ow_token
    'fill_open_weather_map_token_here'
  end
end
