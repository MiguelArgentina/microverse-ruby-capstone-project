require "logger"


class Alogger

  def initialize
  end

  def create_log (log_title, message)
    logfile = Logger.new File.open('./assets/log/weatherbot.log', File::WRONLY | File::APPEND)
    logfile.info(log_title) {message }
    logfile.close()
    return
  end

end
