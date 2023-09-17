# frozen_string_literal: true

require "rbs_settingslogic"
require "settingslogic"

class Config < Settingslogic
  source File.expand_path("config.yml", __dir__)
  namespace "development"
end

RSpec.describe RbsSettingslogic::Settingslogic do
  describe ".generate" do
    subject { described_class.generate(klass) }

    let(:klass) { Config }
    let(:expected) do
      <<~RBS
        class Config < ::Settingslogic
          class Baz < ::Settingslogic
            class Qux < ::Settingslogic
              def self.quux: () -> Integer
            end

            def self.qux: () -> singleton(Qux)
          end

          def self.foo: () -> String
          def self.bar: () -> Array[String]
          def self.baz: () -> singleton(Baz)
        end
      RBS
    end

    it { is_expected.to eq expected }
  end
end
