require 'test_helper'

class ActiveHouseTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ActiveHouse::VERSION
  end

  def test_it_does_something_useful
    assert false
  end

  def test_qwe
    assert_equal 'test', ActiveHouse::Model.select(:foo).where(user_id: 3).to_sql
  end
end
