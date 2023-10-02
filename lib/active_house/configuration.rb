require 'singleton'
require 'clickhouse'
require 'active_support/core_ext/hash/keys'
require 'active_support/concern'

module ActiveHouse
  class Configuration
    include Singleton

    MAIN_NAME = :main
    CONNECTION_KEYS = [
        :url, :urls, :host, :port, :scheme, :database, :username, :password
    ].freeze

    class << self
      alias configuration instance
    end

    attr_reader :connection_config, :logger

    def logger=(value)
      @logger = value
      Clickhouse.logger = @logger
    end

    def connection_config=(value)
      @connection_config = value.deep_symbolize_keys
    end

    def connection_config_for(name = nil)
      name ||= MAIN_NAME
      name = name.to_sym
      config = if name == MAIN_NAME
                 connection_config.key?(name) ? connection_config.fetch(name) : connection_config
               else
                 connection_config.fetch(name)
               end
      config.slice(*CONNECTION_KEYS)
    end
  end
end
