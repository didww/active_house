$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'active_house'

require 'minitest/autorun'

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
