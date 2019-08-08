# frozen_string_literal: true

require 'active_support/concern'

module ActiveHouse
  module Querying
    module Except
      extend ActiveSupport::Concern

      # Chain method
      # @param keys [Array<Symbol>] values keys that you want to exclude from query
      # @return new instance with applied changes
      def except(*keys)
        dup.except!(*keys)
      end

      # Chain method
      # @param keys [Array<Symbol>] values keys that you want to exclude from query
      # @return new instance with applied changes
      def except!(*keys)
        values.merge! initial_values.slice(*keys)
        self
      end

    end
  end
end
