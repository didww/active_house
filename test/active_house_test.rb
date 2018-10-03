require 'test_helper'

class ActiveHouseTest < Minitest::Test
  def assert_query(expected_query, scope)
    assert_equal expected_query.squish, scope.to_query.squish
  end

  def test_that_it_has_a_version_number
    refute_nil ::ActiveHouse::VERSION
  end

  def test_simple_query
    expected_query = <<-SQL
      SELECT foo
      FROM db.some_table
      WHERE user_id = 3
      LIMIT 2, 3
    SQL
    scope = TestModel.select(:foo).where(user_id: 3).limit(2, 3)
    assert_query expected_query, scope
  end

  def test_query
    expected_query = <<-SQL
      SELECT time_start, duration > 0 AS success, src
      FROM incoming.calls
      WHERE user_id = 3
    SQL
    scope = IncomingCall.select(:time_start, 'duration > 0 AS success', :src).where(user_id: 3)
    assert_query expected_query, scope
  end
end
