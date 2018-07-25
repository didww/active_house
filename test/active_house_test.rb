require 'test_helper'

class ActiveHouseTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ActiveHouse::VERSION
  end

  def test_simple_query
    expected_query = <<-SQL.squish
      SELECT foo
      FROM db.some_table
      WHERE user_id = 3
      LIMIT 2, 3
    SQL
    assert_equal expected_query, TestModel.select(:foo).where(user_id: 3).limit(2, 3).to_query.squish
  end
end
