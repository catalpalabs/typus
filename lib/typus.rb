module Typus

  class << self

    def applications
      apps = []
      Typus::Configuration.config.to_a.each do |model|
        if model[1].has_key? 'application'
          apps << model[1]['application']
        end
      end
      return apps.uniq.sort
    end

    def modules(app_name)
      submodules = []
      Typus::Configuration.config.to_a.each do |model|
        if model[1]['application'] == app_name
          submodules << model[0]
        end
      end
      return submodules.sort
    end

    def submodules(module_name)
      submodules = []
      Typus::Configuration.config.to_a.each do |model|
        if model[1]['module'] == module_name
          submodules << model[0]
        end
      end
      return submodules.sort
    end

    def parent_module(submodule_name)
      Typus::Configuration.config[submodule_name]['module']
    end

    def parent_application(module_name)
      Typus::Configuration.config[module_name]['application']
    end

    def models
      m = []
      Typus::Configuration.config.to_a.each do |model|
        m << model[0]
      end
      return m.sort
    end

    def version
      VERSION::STRING
    end

    def enable
      Typus::Configuration.config!
      Typus::Configuration.roles!
      require 'typus/version'
      require File.dirname(__FILE__) + "/../test/test_models" if RAILS_ENV == 'test'
      require 'typus/active_record'
      require 'typus/routes'
      require 'typus/string'
      require 'typus/hash'
      require 'typus/authentication'
      require 'typus/patches' if Rails.vendor_rails?
      require 'typus/object'
      require 'vendor/paginator'
      require 'vendor/environments'
    end

    def generate_controllers

      ##
      # Create app/controllers/admin if doesn't exist.
      #
      admin_controllers_folder = "#{RAILS_ROOT}/app/controllers/admin"
      Dir.mkdir(admin_controllers_folder) unless File.directory?(admin_controllers_folder)

      ##
      # Get a list of all the available app/controllers/admin
      #
      admin_controllers = Dir['vendor/plugins/*/app/controllers/admin/*.rb']
      admin_controllers += Dir['app/controllers/admin/*.rb']
      admin_controllers = admin_controllers.map { |i| i.split("/").last }

      ##
      # Create app/helpers/admin if doesn't exist.
      #
      admin_helpers_folder = "#{RAILS_ROOT}/app/helpers/admin"
      Dir.mkdir(admin_helpers_folder) unless File.directory?(admin_helpers_folder)

      ##
      # Get a list of all the available app/helpers/admin
      #
      admin_helpers = Dir['vendor/plugins/*/app/helpers/admin/*.rb']
      admin_helpers += Dir['app/helpers/admin/*.rb']
      admin_helpers = admin_helpers.map { |i| i.split("/").last }

      ##
      # Create test/functional/admin if doesn't exist.
      #
      admin_controller_tests_folder = "#{RAILS_ROOT}/test/functional/admin"
      Dir.mkdir(admin_controller_tests_folder) unless File.directory?(admin_controller_tests_folder)

      ##
      # Get a list of all the available app/helpers/admin
      #
      admin_controller_tests = Dir['vendor/plugins/*/test/functional/admin/*.rb']
      admin_controller_tests += Dir['test/functional/admin/*.rb']
      admin_controller_tests = admin_controller_tests.map { |i| i.split("/").last }

      ##
      # Generate unexisting controllers.
      #
      self.models.each do |model|

        ##
        # Controller app/controllers/admin/*
        #

        controller_filename = "#{model.tableize}_controller.rb"
        controller_location = "#{admin_controllers_folder}/#{controller_filename}"

        if !admin_controllers.include?(controller_filename)
          controller = File.open(controller_location, "w+")

          content = <<-RAW
##
# Controller auto-generated by Typus.
# Use it to extend the admin functionality.
##
class Admin::#{model.pluralize}Controller < AdminController

=begin

  ##
  # You can overwrite any of the AdminController methods.
  #
  def index
  end

  ##
  # You can extend the AdminController with your actions.
  #
  # This actions have to be defined in `typus.yml`.
  #
  #   Post:
  #     actions:
  #       list: action_for_the_listing
  #       form: action_for_the_form
  #
  def your_action
  end

=end

end

          RAW

          controller.puts(content)
          controller.close
          puts "=> Admin::#{model.pluralize}Controller successfully created."
        end

        ##
        # Helper app/helpers/admin/*
        #
        helper_filename = "#{model.tableize}_helper.rb"
        helper_location = "#{admin_helpers_folder}/#{helper_filename}"

        if !admin_helpers.include?(helper_filename)
          helper = File.open(helper_location, "w+")

          content = <<-RAW
##
# Helper auto-generated by Typus.
# Use it to extend the admin functionality.
##
module Admin::#{model.pluralize}Helper

end
          RAW

          helper.puts(content)
          helper.close
          puts "=> Admin::#{model.pluralize}Helper successfully created."
        end

        ##
        # Test test/functional/admin/*_test.rb
        #
        test_filename = "#{model.tableize}_controller_test.rb"
        test_location = "#{admin_controller_tests_folder}/#{test_filename}"

        if !admin_controller_tests.include?(test_filename)
          test = File.open(test_location, "w+")

          content = <<-RAW
##
# Test auto-generated by Typus.
# Use it to test the extended admin functionality.
##
require 'test_helper'

class Admin::#{model.pluralize}ControllerTest < ActionController::TestCase

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

end
          RAW

          test.puts(content)
          test.close
          puts "=> Admin::#{model.pluralize}ControllerTest successfully created."
        end

      end
    end

  end

end