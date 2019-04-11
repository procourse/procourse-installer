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

    def uninstall
      raise Discourse::NotFound unless params[:plugin_name].present?

      installed_plugins = ProcourseInstaller::InstalledPlugins.get
      plugin_to_remove = installed_plugins.select { |plugin| plugin[:name] == params[:plugin_name] } unless installed_plugins.nil?

      # Uninstall plugin
      launcher_pid = unicorn_launcher_pid
      master_pid = unicorn_master_pid
      workers = unicorn_workers(master_pid).size

      begin
        reload_unicorn(launcher_pid)

        num_workers_spun_down = workers - 1

        if num_workers_spun_down.positive?
          (num_workers_spun_down).times { Process.kill("TTOU", unicorn_master_pid) }
        end

        if ENV["UNICORN_SIDEKIQS"].to_i > 0
          Process.kill("TSTP", unicorn_master_pid)
          sleep 1
          # older versions do not have support, so quickly send a cont so master process is not hung
          Process.kill("CONT", unicorn_master_pid)
        end

        # DO STUFF HERE
        `cd /var/www/discourse/plugins && rm -r #{params[:plugin_name]}`

        reload_unicorn(launcher_pid)

        # Remove from bootstrap file

        bootstrap_file = File.readlines('/shared/tmp/procourse-installer/plugins.txt')
        bootstrap_file.delete_if { |line| line == plugin_to_remove[:url] }

        # Remove from PluginStore
        ProcourseInstaller::InstalledPlugins.remove(plugin_to_remove)
      rescue 
        STDERR.puts("Whoops.")
    end

    private

    def unicorn_launcher_pid
      `ps aux  | grep unicorn_launcher | grep -v sudo | grep -v grep | awk '{ print $2 }'`.strip.to_i
    end

    def unicorn_master_pid
      `ps aux | grep "unicorn master -E" | grep -v "grep" | awk '{print $2}'`.strip.to_i
    end

    def unicorn_workers(master_pid)
      `ps -f --ppid #{master_pid} | grep worker | awk '{ print $2 }'`
        .split("\n")
        .map(&:to_i)
    end

    def reload_unicorn(launcher_pid)
      original_master_pid = unicorn_master_pid
      Process.kill("USR2", launcher_pid)

      iterations = 0
      while pid_exists?(original_master_pid) do
        iterations += 1
        break if iterations >= 60
        sleep 1
      end

      iterations = 0
      while `curl -s #{local_web_url}` != "ok" do
        iterations += 1
        break if iterations >= 60
        sleep 1
      end
    end
  end
end
