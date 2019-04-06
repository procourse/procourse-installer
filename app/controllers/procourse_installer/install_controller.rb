module ProcourseInstaller
  class InstallController < ApplicationController

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

      render plain: "OK"
    end

  end
end
