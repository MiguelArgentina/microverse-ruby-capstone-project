# :nodoc:
class Tokens

  def initialize

  end

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
    telegram_token = ''
  end

  def ow_token
    ow_token = ''
  end
end
