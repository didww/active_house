require 'active_support/concern'

module ActiveHouse
  module Querying
    module Scope
      extend ActiveSupport::Concern

      included do
        private :apply_scope, :scope?
      end

      class_methods do
        def new(*)
          super._apply_default_scope
        end
      end

      def _apply_default_scope
        return self if model_class._default_scope.nil?
        apply_scope(model_class._default_scope)
      end

      def respond_to_missing?(method_name, *_args)
        scope?(method_name) || super
      end

      def method_missing(method_name, *args, &_block)
        if scope?(method_name)
          apply_scope(method_name, *args)
        else
          super
        end
      end

      def apply_scope(name, *args)
        scope = model_class._scopes.fetch(name)
        instance_exec(*args, &scope)
      end

      def scope?(name)
        model_class.scope?(name.to_sym)
      end
    end
  end
end
