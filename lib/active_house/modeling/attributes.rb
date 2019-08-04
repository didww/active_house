require 'active_support/concern'

module ActiveHouse
  module Modeling
    module Attributes
      extend ActiveSupport::Concern

      included do
        class_attribute :_attribute_opts, instance_writer: false
        self._attribute_opts = {}

        private

        def parse_attribute_method_name(method_name)
          name, is_setter = method_name.to_s.match(/\A(.+)?(=)?\z/).captures
          name = name.to_sym
          is_setter = !is_setter.nil?
          [name, is_setter]
        end

        def attribute_method?(name, is_setter, *args)
          (_attribute_opts.key?(name) || @_attributes.key?(name)) && (is_setter ? args.size == 1 : true)
        end

        def get_attribute(name)
          @_attributes[name]
        end

        def set_attribute(name, value)
          opts = _attribute_opts.fetch(name, {})
          value = opts[:cast].call(value) if opts[:cast]
          @_attributes[name] = value
        end
      end

      class_methods do
        def attribute(name, options = {})
          name = name.to_sym
          self._attribute_opts = _attribute_opts.merge(name => options)
          define_method(name) do
            get_attribute(name)
          end
          define_method("#{name}=") do |value|
            set_attribute(name, value)
          end
        end

        def attributes(*names)
          options = names.extract_options!
          names.each { |name| attribute(name, options.dup) }
        end

        def load!(params)
          new.tap do |model|
            params.each { |name, value| model[name] = value }
          end
        end
      end

      def initialize(params = {})
        @_attributes = {}
        assign_attributes(params) unless params.nil?
      end

      def as_json(*_args)
        to_h
      end

      def to_h
        @_attributes.dup
      end

      def [](key)
        get_attribute(key.to_sym)
      end

      def []=(key, value)
        set_attribute(key.to_sym, value)
      end

      def assign_attributes(params)
        params.each do |key, val|
          public_send("#{key}=", val)
        end
      end

      def respond_to_missing?(method_name, *args)
        name, is_setter = parse_attribute_method_name(method_name)
        attribute_method?(name, is_setter, *args)
      end

      def method_missing(method_name, *args, &block)
        name, is_setter = parse_attribute_method_name(method_name)
        if attribute_method?(name, is_setter, *args)
          is_setter ? set_attribute(name, args.first) : get_attribute(name)
        else
          super
        end
      end
    end
  end
end
