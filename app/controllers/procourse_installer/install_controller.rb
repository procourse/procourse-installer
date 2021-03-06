module ProcourseInstaller
  class InstallController < ApplicationController
    def status
      @@install_state || false
    end

    def show
      plugins = ProcourseInstaller::InstalledPlugins.get

      plugins.map { |plugin| plugin.except!(:url) }

      render_json_dump(plugins)
    end

    def install
      raise Discourse::NotFound unless params[:plugin_url].present?

      if params[:plugin_url].end_with? ".git"
        plugin_url = params[:plugin_url]
      else
        plugin_url = params[:plugin_url] + ".git"
      end

      `cd /var/www/discourse/plugins && git clone #{plugin_url}`

      dir = plugin_url.match(/([^\/]+)\/?$/)[0][0..-5]
      repo = DockerManager::GitRepo.new('/var/www/discourse/plugins/' + dir, dir)
      repo.stop_upgrading
      upgrader = DockerManager::Upgrader.new(current_user.id,repo,nil)

      @@install_state = true

      pid = fork do
        exit if fork
        Process.setsid
        exit if fork
        upgrader.upgrade
      end

      Process.waitpid(pid)

      # Add to plugin store for in-app UI
      plugin_info = {
        :name => dir,
        :installed_on => Time.now(),
        :installed_by => current_user.username,
        :url => plugin_url
      }
      ProcourseInstaller::InstalledPlugins.add(plugin_info)

      # Add to text file for on-bootstrap plugin install task
      `mkdir /shared/tmp/procourse-installer` unless Dir.exist?('/shared/tmp/procourse-installer')
      plugin_file = File.new('/shared/tmp/procourse-installer/plugins.txt', 'a')
      plugin_file.write("#{plugin_url}\n")
      plugin_file.close

      @@install_state = false

      render plain: "OK"
    end

    def uninstall
      raise Discourse::NotFound unless params[:plugin_name].present?

      installed_plugins = ProcourseInstaller::InstalledPlugins.get
      plugin_to_remove = installed_plugins.select { |plugin| plugin[:name] == params[:plugin_name] } unless installed_plugins.nil?

      repo = DockerManager::GitRepo.new('/var/www/discourse/plugins/' + params[:plugin_name], params[:plugin_name])
      repo.stop_upgrading
      remover = DockerManager::Upgrader.new(current_user.id, repo, nil)

      pid = fork do
        exit if fork
        Process.setsid
        exit if fork
        remover.remove(plugin_to_remove[0])
      end

      Process.waitpid(pid)

      # Remove from PluginStore
      ProcourseInstaller::InstalledPlugins.remove(plugin_to_remove[0])

      # Remove from bootstrap file
      bootstrap_file = File.readlines('/shared/tmp/procourse-installer/plugins.txt')
      bootstrap_file.delete_if { |line| line.include?(plugin_to_remove[0][:url]) }

      File.open('/shared/tmp/procourse-installer/plugins.txt', 'w+') do |f|
        f.puts(bootstrap_file)
      end

      render plain: "OK"
    end
  end
end
