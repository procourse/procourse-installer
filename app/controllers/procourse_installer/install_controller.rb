module ProcourseInstaller
  class InstallController < ApplicationController
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

      render plain: "OK"
    end

  end
end
