$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'active_house'

require 'minitest/autorun'
require 'webmock/minitest'

ActiveHouse.configure do |config|
  config.connection_config = { url: 'https://clickhouse.example.com:1234' }
end

class TestModel < ActiveHouse::Model
  table_name 'db.some_table'
end

class IncomingCall < ActiveHouse::Model
  table_name 'incoming.calls'
  attributes :id, :duration, :timestamp, :src, :dst, :user_id, :call_start_timestamp, :call_end_timestamp
end

class OutgoingCall < ActiveHouse::Model
  table_name 'outgoing.calls'
  attributes :id, :duration, :timestamp, :src, :dst, :user_id, :call_start_timestamp, :call_end_timestamp
end

class PathObject < ActiveHouse::Model
  table_name 'canvas.path_objects'
  attributes :name, :dots, :distances
  attribute :user_id, cast: ->(value) { value.try!(:to_i) }
end
