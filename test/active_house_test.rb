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

  def test_query_union
    expected_query = <<-SQL
      SELECT time_start, duration > 0 AS success, src AS number, 1 AS direction
      FROM incoming.calls
      WHERE user_id = 3
      UNION ALL
      SELECT time_start, duration > 0 AS success, dst AS number, 2 AS direction
      FROM outgoing.calls
      WHERE user_id = 3
    SQL
    expected_subquery = <<-SQL
      SELECT time_start, duration > 0 AS success, dst AS number, 2 AS direction
      FROM outgoing.calls
      WHERE user_id = 3 AND src = '123456'
    SQL
    expected_without_union = <<-SQL
      SELECT time_start, duration > 0 AS success, src AS number, 1 AS direction
      FROM incoming.calls
      WHERE user_id = 3 AND duration = 0
    SQL
    outgoing_scope = OutgoingCall.select(:time_start, 'duration > 0 AS success', 'dst AS number', '2 AS direction')
    scope = IncomingCall.select(:time_start, 'duration > 0 AS success', 'src AS number', '1 AS direction')
                        .where(user_id: 3).union(:out, outgoing_scope).update_union(:out) { |s| s.where(user_id: 3) }
    sub_scope = scope.union_for(:out).where(src: '123456')
    without_union = scope.except_union(:out).where(duration: 0)
    assert_query expected_query, scope
    assert_query expected_subquery, sub_scope
    assert_query expected_without_union, without_union
  end

  def test_subquery
    expected_query = <<-SQL
      SELECT COUNT(success) AS success_qty, COUNT(time_start) AS all_qty, toStartOfDay(time_start) AS start_date
      FROM (
        SELECT id, time_start, duration > 0 AS success
        FROM incoming.calls
        WHERE user_id = 3
      )
      GROUP BY toStartOfDay(time_start)
    SQL
    subquery = IncomingCall.select(:id, :time_start, 'duration > 0 AS success').where(user_id: 3)
    scope = ActiveHouse::Query.new.from(subquery)
                              .select(
                                'COUNT(success) AS success_qty',
                                'COUNT(time_start) AS all_qty',
                                'toStartOfDay(time_start) AS start_date'
                              ).group_by('toStartOfDay(time_start)')
    assert_query expected_query, scope
  end

  def test_array_join
    expected_query = <<-SQL
      SELECT name, distances, dot.x, dot.y
      FROM canvas.path_objects ARRAY JOIN distances, dots AS dot
      WHERE user_id = 3
    SQL
    scope = PathObject.select(:name, :distances, 'dot.x', 'dot.y')
                      .array_join(:distances, 'dots AS dot').where(user_id: 3)
    assert_query expected_query, scope
  end

  def test_attribute_cast
    p1 = PathObject.new
    assert_nil p1.user_id
    assert_nil p1[:user_id]
    assert_nil p1['user_id']

    p2 = PathObject.new(user_id: nil)
    assert_nil p2.user_id
    assert_nil p2[:user_id]
    assert_nil p2['user_id']

    p3 = PathObject.new(user_id: 2)
    assert_equal 2, p3.user_id
    assert_equal 2, p3[:user_id]
    assert_equal 2, p3['user_id']

    p4 = PathObject.new(user_id: '2')
    assert_equal 2, p4.user_id
    assert_equal 2, p4[:user_id]
    assert_equal 2, p4['user_id']

    p5 = PathObject.new(user_id: 2.1)
    assert_equal 2, p5.user_id
    assert_equal 2, p5[:user_id]
    assert_equal 2, p5['user_id']

    p6 = PathObject.new
    p6.user_id = '2'
    assert_equal 2, p6.user_id
    assert_equal 2, p6[:user_id]
    assert_equal 2, p6['user_id']

    p7 = PathObject.new
    p7['user_id'] = '2'
    assert_equal 2, p7.user_id
    assert_equal 2, p7[:user_id]
    assert_equal 2, p7['user_id']

    p8 = PathObject.new
    p8[:user_id] = '2'
    assert_equal 2, p8.user_id
    assert_equal 2, p8[:user_id]
    assert_equal 2, p8['user_id']
  end
end
