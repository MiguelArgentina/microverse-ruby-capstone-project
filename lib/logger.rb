require 'logger'

# :nodoc:
module Alogger
  # def initialize(_aux = nil)
  #
  # end

  def logger_create_log(log_title, message)
    file = File.open('./assets/log/weatherbot.log', File::WRONLY | File::APPEND)
    logfile = Logger.new(file)
    logfile.info(log_title) { message }
    return true if logfile.close

    false
  end
end
