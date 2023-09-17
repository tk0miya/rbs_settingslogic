# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "rbs"

module RbsSettingslogic
  module Settingslogic
    def self.generate(klass)
      Generator.new(klass).generate
    end

    class Generator
      attr_reader :klass

      def initialize(klass)
        @klass = klass
      end

      def generate
        format <<~RBS
          class #{klass.name} < ::Settingslogic
            #{generate_classes(klass)}
            #{generate_methods(klass)}
          end
        RBS
      end

      private

      def format(rbs)
        parsed = RBS::Parser.parse_signature(rbs)
        StringIO.new.tap do |out|
          RBS::Writer.new(out: out).write(parsed[1] + parsed[2])
        end.string
      end

      def generate_classes(config)
        config.filter_map do |key, value|
          next unless value.is_a?(Hash)

          <<~RBS
            class #{key.to_s.camelize} < ::Settingslogic
              #{generate_classes(value)}
              #{generate_methods(value)}
            end
          RBS
        end.join("\n")
      end

      def generate_methods(config)
        config.map do |key, value|
          "def self.#{key}: () -> #{stringify_type(key, value)}"
        end.join("\n")
      end

      def stringify_type(name, value)
        case value
        when Hash
          "singleton(#{name.camelize})"
        when Array
          types = value.map { |v| stringify_type(name, v) }.uniq
          "Array[#{types.join(" | ")}]"
        when NilClass
          "nil"
        when TrueClass, FalseClass
          "bool"
        else
          value.class.to_s
        end
      end
    end
  end
end
