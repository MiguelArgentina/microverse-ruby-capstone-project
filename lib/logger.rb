require 'logger'

# :nodoc:
class Alogger

  def initialize()

  end

  def log_creator_handler(private_method, *params)
    method(private_method.to_sym).call(params)
  end

  private
  def logger_create_log(*params)
    what_to_return = true
    begin
      file = File.open('./assets/log/weatherbot.log', File::WRONLY | File::APPEND)
      logfile = Logger.new(file)
      logfile.info(params[0]) { params[1] }

    rescue
      what_to_return = false
    ensure
      logfile.close unless logfile.nil?
      what_to_return
    end

  end
end
