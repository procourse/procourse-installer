module ProcourseInstaller
  class InstalledPlugins
    @store_key = 'installed_plugins'

    def self.get
      PluginStore.get('procourse_installer', @store_key) || []
    end
    
    def self.add(plugin_url)
      plugins = get

      plugins.push(plugin_url) unless plugins.include?(plugin_url)

      PluginStore.set('procourse_installer', @store_key, plugins)
    end

    def self.remove(plugin_url)
      plugins = get

      plugins.delete(plugin_url)

      PluginStore.set('procourse_installer', @store_key, plugins)
    end
  end
end
