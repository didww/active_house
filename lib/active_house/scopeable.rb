require 'active_support/concern'

module ActiveHouse
  module Scopeable
    extend ActiveSupport::Concern

    included do
      private

      def apply_scope(name)
        scope = model_class._scopes.fetch(name.to_sym)
        instance_exec(*args, &scope)
      end

      def scope?(name)
        model_class._scopes.key?(name.to_sym)
      end

      def apply_default_scope
        apply_scope(model_class._default_scope) unless model_class._default_scope.nil?
      end
    end

    def initialize(*)
      super
      with_current_query { apply_default_scope }
    end

    def respond_to_missing?(method_name, *_args)
      scope?(method_name) || super
    end

    def method_missing(method_name, *args, &_block)
      if scope?(method_name)
        apply_scope(method_name)
      else
        super
      end
    end
  end
end
