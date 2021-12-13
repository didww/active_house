require 'active_house/version'
require 'active_house/configuration'
require 'active_house/model'
require 'active_house/query_builder'

require 'clickhouse/connection/post_query'
Clickhouse::Connection.include Clickhouse::Connection::PostQuery

module ActiveHouse
  def self.configure
    yield configuration
  end

  def self.configuration
    ActiveHouse::Configuration.configuration
  end
end
