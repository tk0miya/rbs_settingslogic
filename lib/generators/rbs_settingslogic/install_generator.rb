# frozen_string_literal: true

require "rails"

module RbsSettingslogic
  class InstallGenerator < Rails::Generators::Base
    def create_raketask
      create_file "lib/tasks/rbs_settingslogic.rake", <<~RUBY
        begin
          require 'rbs_settingslogic/rake_task'

          RbsSettingslogic::RakeTask.new
        rescue LoadError
          # failed to load rbs_settingslogic. Skip to load rbs_settingslogic tasks.
        end
      RUBY
    end
  end
end
