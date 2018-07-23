require_relative 'connection_error'
require_relative 'prepared_statement'
require 'clickhouse/cluster'
require 'clickhouse/connection'

module ActiveHouse
  class Connection
    attr_reader :config

    def initialize(config)
      config.assert_valid_keys(:url, :urls, :database, :username, :password, :host, :port, :scheme)
      @config = config
      @connection = nil
      ensure_connected!
    end

    def execute(sql, *bindings)
      prepared_sql = prepared_statement(sql, *bindings)
      connection.execute(prepared_sql)
    end

    def select_all(sql, *bindings)
      prepared_sql = prepared_statement(sql, *bindings)
      connection.query(prepared_sql)
    end

    def select_values(sql, *bindings)
      select_all(sql, *bindings).flatten
    end

    def select_value(sql, *bindings)
      select_all(sql, *bindings).flatten.first
    end

    def select_row(sql, *bindings)
      select_all(sql, *bindings).to_hashes.first
    end

    def select_rows(sql, *bindings)
      select_all(sql, *bindings).to_hashes
    end

    def connection_alive?
      return false if connection.nil?
      if connection.is_a?(Clickhouse::Cluster)
        !connection.pond.available.empty?
      else
        begin
          connection.ping!
          true
        rescue StandardError
          false
        end
      end
    end

    def reconnect!
      ensure_connected!
    end

    private

    def prepared_statement(sql, *bindings)
      ActiveHouse::PreparedStatement.prepare_sql(sql, *bindings)
    end

    attr_reader :connection

    def ensure_connected!
      @connection = establish_connection unless connection_alive?
      raise ActiveHouse::ConnectionError unless connection_alive?
    end

    def establish_connection
      if config.key?(:urls)
        Clickhouse::Cluster.new(config)
      else
        Clickhouse::Connection.new(config)
      end
    end
  end
end
