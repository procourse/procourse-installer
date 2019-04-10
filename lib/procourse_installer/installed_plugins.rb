module ProcourseInstaller
  class InstalledPlugins
    @store_key = 'installed_plugins'

    def self.get
      PluginStore.get('procourse_installer', @store_key) || []
    end
    
    def self.add(plugin)
      plugins = get

      plugins.push(plugin) unless plugins.select { |installed_plugin| installed_plugin['name'] == plugin['name'] }

      PluginStore.set('procourse_installer', @store_key, plugins)
    end

    def self.remove(plugin)
      plugins = get

      plugins.reject { |json| json['name'] == plugin['name'] }

      PluginStore.set('procourse_installer', @store_key, plugins)
    end
  end
end
