require 'logger'
require_relative '../lib/tokens'

describe Tokens do
  context ' calls a method to return a token ' do
    it 'calls the .get_token method and gets a string with the token' do
      expect((Tokens.new).get_token(:ow)).to be_a(String)
    end
    it 'calls the .get_token method and gets a string that should not be empty' do
      expect((Tokens.new).get_token(:ow)).not_to be_empty
    end
  end
end
