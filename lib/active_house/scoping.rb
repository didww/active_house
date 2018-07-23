require 'active_support/concern'

module ActiveHouse
  module Scoping
    extend ActiveSupport::Concern

    included do
      class_attribute :_default_scope, instance_accessor: false
      class_attribute :_scopes, instance_accessor: false
      self._scopes = {}
    end

    class_methods do
      def default_scope(name)
        self._default_scope = name.to_sym
      end

      def scope(name, block)
        self._scopes = _scopes.merge(name.to_sym => block)
      end

      def respond_to_missing?(method_name, *_args)
        _scopes.key?(method_name.to_sym)
      end

      def method_missing(method_name, *args, &_block)
        method_name = method_name.to_sym
        if _scopes.key?(method_name)
          scope = _scopes.fetch(method_name)
          all.instance_exec(*args, &scope)
        else
          super
        end
      end
    end
  end
end
