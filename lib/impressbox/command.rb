require 'vagrant'
require_relative File.join('objects', 'template')

# Impressbox
module Impressbox
  # Command class
  class Command < Vagrant.plugin('2', :command)
    DEFAULT_VALUES = {
      box: 'ImpressCMS/DevBox-Ubuntu',
      ip: nil,
      hostname: 'impresscms.dev',
      memory: 512,
      cpus: 1,
      cmd: 'php /vagrant/www/cmd.php'
    }.freeze

    OPTIONS = [
      {
        short: '-b',
        full: '--box BOX_NAME',
        description: "Box name for new box (default: #{DEFAULT_VALUES[:box]})",
        option: :box
      },
      {
        short: nil,
        full: '--ip IP',
        description: "Defines IP (default: #{DEFAULT_VALUES[:ip]})",
        option: :ip
      },
      {
        short: nil,
        full: '--url HOSTNAME',
        description: "Hostname associated with this box (default: #{DEFAULT_VALUES[:hostname]})",
        option: :hostname
      },
      {
        short: nil,
        full: '--memory RAM',
        description: "How much RAM (in megabytes)? (default: #{DEFAULT_VALUES[:memory]})",
        option: :memory
      },
      {
        short: nil,
        full: '--cpus CPU_NUMBER',
        description: "How much CPU? (default: #{DEFAULT_VALUES[:cpus]})",
        option: :cpus
      },
      {
        short: nil,
        full: '--cmd CMD_NAME',
        description: "What command would be executed when use vagrant exec on host? (default: #{DEFAULT_VALUES[:cmd]})",
        option: :cpus
      },
      {
        short: '-r',
        full: '--recreate',
        description: "Recreates config instead of updating (so you don't need to delete first)",
        option: :___recreate___
      }
    ].freeze

    def self.synopsis
      'Creates a Vagrantfile and config.yaml ready for use with ImpressBox'
    end

    def execute
      prepare_options
      @template = Impressbox::Objects::Template.new
      write_result_msg do_prepare unless argv.nil?
      0
    end

    private

    def prepare_options
      @options = DEFAULT_VALUES.dup
      @options[:name] = make_name
      @options[:info] = {
        last_update: Time.now.to_s,
        website_url: 'http://impresscms.org'
      }
    end

    def argv
      parse_options create_option_parser(@options)
    end

    def write_result_msg(result)
      if result
        puts 'Vagrant enviroment configuration (re)created'
      else
        puts 'Vagrant enviroment configuration updated'
      end
    end

    def do_prepare
      @template.do_quick_prepare vagrantfile_filename, @options, must_recreate
      @template.do_quick_prepare config_yaml_filename, @options, must_recreate
    end

    def must_recreate
      @options[:___recreate___]
    end

    def make_name
      @options[:hostname].gsub(/[^A-Za-z0-9_-]/, '-')
    end

    def make_config
      @template.prepare_file read_config_yaml, 'config.yaml', @options
    end

    def config_yaml_filename
      File.join @template.templates_path, 'config.yaml'
    end

    def vagrantfile_filename
      File.join @template.templates_path, 'Vagrantfile'
    end

    def create_option_parser(options)
      OptionParser.new do |o|
        o.banner = 'Usage: vagrant impressbox'
        o.separator ''

        OPTIONS.each do |option|
          o.on(option[:short], option[:full], option[:description]) do |f|
            options[option[:option]] = f
          end
        end
      end
    end
  end
end
