require 'active_support/core_ext/class/attribute'
require 'active_support/concern'
require_relative '../connection'
require_relative '../configuration'

module ActiveHouse
  module Modeling
    module Connection
      extend ActiveSupport::Concern

      included do
        class_attribute :_connection_class, instance_accessor: false
        self._connection_class = ActiveHouse::Connection
      end

      class_methods do
        def _connection
          Thread[name]
        end

        def _connection=(value)
          Thread[name] = value
        end

        def ensure_connection
          establish_connection if _connection.nil?
        end

        def establish_connection(name_or_config = nil)
          config = if name_or_config.is_a?(Hash)
                     name_or_config.symbolize_keys
                   else
                     ActiveHouse.configuration.connection_config_for(name_or_config)
                   end
          self._connection = _connection_class.new(config)
        end

        def connection
          ensure_connection
          _connection
        end
      end
    end
  end
end
