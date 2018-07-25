$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'active_house'

require 'minitest/autorun'

class TestModel < ActiveHouse::Model
  table_name 'db.some_table'
end
