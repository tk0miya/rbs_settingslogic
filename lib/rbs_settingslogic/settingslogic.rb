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
          case value
          when Hash
            <<~RBS
              class #{key.to_s.camelize} < ::Settingslogic
                #{generate_classes(value)}
                #{generate_methods(value)}
              end
            RBS
          when Array
            value.filter_map.with_index do |v, i|
              case v
              when Hash
                <<~RBS
                  class #{key.to_s.camelize}#{i} < ::Settingslogic
                    #{generate_classes(v)}
                    #{generate_methods(v)}
                  end
                RBS
              end
            end.join("\n")
          end
        end.join("\n")
      end

      def generate_methods(config)
        config.map do |key, value|
          "def self.#{key}: () -> #{stringify_type(key, value)}"
        end.join("\n")
      end

      def stringify_type(name, value, index = nil)
        case value
        when Hash
          "singleton(#{name.camelize}#{index})"
        when Array
          types = value.map.with_index { |v, i| stringify_type(name, v, i) }.uniq
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
