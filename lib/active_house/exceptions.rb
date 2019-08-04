module ActiveHouse
  module Exceptions
    class Error < ::StandardError
    end

    class ConnectionError < Error
    end
  end
end
