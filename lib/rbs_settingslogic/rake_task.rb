# frozen_string_literal: true

require "active_support/core_ext/class"
require "pathname"
require "rake/tasklib"

module RbsSettingslogic
  class RakeTask < Rake::TaskLib
    attr_accessor :name, :signature_root_dir

    def initialize(name = :"rbs:settingslogic", &block)
      super()

      @name = name
      @signature_root_dir = Rails.root / "sig/settingslogic"

      block&.call(self)

      define_clean_task
      define_generate_task
      define_setup_task
    end

    def define_setup_task
      desc "Run all tasks of rbs_settingslogic"

      deps = [:"#{name}:clean", :"#{name}:generate"]
      task("#{name}:setup" => deps)
    end

    def define_generate_task
      desc "Generate RBS files for settingslogic gem"
      task "#{name}:generate": :environment do
        require "rbs_settingslogic"  # load RbsSettingslogic lazily

        Rails.application.eager_load!

        ::Settingslogic.descendants.each do |klass|
          path = signature_root_dir / "#{klass.name.to_s.underscore}.rbs"
          path.dirname.mkpath
          path.write(RbsSettingslogic::Settingslogic.generate(klass))
        end
      end
    end

    def define_clean_task
      desc "Clean RBS files for settingslogic gem"
      task "#{name}:clean": :environment do
        signature_root_dir.rmtree if signature_root_dir.exist?
      end
    end
  end
end
