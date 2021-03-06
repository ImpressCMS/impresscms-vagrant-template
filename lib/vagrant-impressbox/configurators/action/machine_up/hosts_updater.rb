module Impressbox
  module Configurators
    module Action
      module MachineUp
        # Updates hosts
        class HostsUpdater < Impressbox::Abstract::ConfiguratorAction

          # This method is used to configure/run configurator
          #
          #@param app         [Object]                            App instance
          #@param env         [Hash]                              Current loaded environment data
          #@param config_file [::Impressbox::Objects::ConfigFile] Loaded config file data
          #@param machine     [::Vagrant::Machine]                Current machine
          def configure(app, env, config_file, machine)
            require 'vagrant-hostmanager/provisioner'
            instance = VagrantPlugins::HostManager::HostsFile::Updater.new(machine.env, machine.provider_name)
            instance.update_guest machine
            instance.update_host
          end

          # This method is used for description
          #
          #@return [String]
          def description
            I18n.t('configuring.hosts')
          end

        end
      end
    end
  end
end
