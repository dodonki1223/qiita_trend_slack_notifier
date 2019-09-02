# frozen_string_literal: true

module QiitaNotifier
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end

  class Configuration
    attr_accessor :user_name, :password, :web_hook_url, :channel

    def initialize
      @user_name = nil
      @password = nil
      @web_hook_url = nil
      @channel = nil
    end
  end
end
