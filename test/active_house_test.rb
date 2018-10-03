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
      ORDER BY foo ASC
      LIMIT 2, 3
    SQL
    scope = TestModel.select(:foo).where(user_id: 3).limit(2, 3).order_by(foo: :asc)
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

  def test_query_group_by_and_having
    expected_query = <<-SQL
      SELECT SUM(duration > 0) AS sum_duration, src
      FROM incoming.calls
      GROUP BY src
      HAVING sum_duration > 0
    SQL
    scope = IncomingCall.select('SUM(duration > 0) AS sum_duration', :src).group_by(:src).having('sum_duration > ?', 0)
    assert_query expected_query, scope
  end
end
