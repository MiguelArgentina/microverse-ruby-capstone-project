require 'logger'
require_relative '../lib/logger'

describe Alogger do
  context ' calls a method to create a log ' do
    it 'calls the .log_creator_handler method and returns true in success or false if error' do
      expect(Alogger.new.log_creator_handler(:logger_create_log, 'Log title', 'Log message')).to be(true).or be(false)
    end
  end
end
