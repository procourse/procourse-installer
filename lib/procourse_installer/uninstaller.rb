class ProcourseInstaller::Uninstaller

  def initialize(plugin)
    @plugin = plugin
  end

  def uninstall
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
      `cd /var/www/discourse/plugins && rm -r #{@plugin[:name]}`

      reload_unicorn(launcher_pid)

      # Remove from bootstrap file

      bootstrap_file = File.readlines('/shared/tmp/procourse-installer/plugins.txt')
      bootstrap_file.delete_if { |line| line == @plugin[:url] }

      # Remove from PluginStore
      ProcourseInstaller::InstalledPlugins.remove(@plugin)
    rescue
      STDERR.puts("Whoops.")
    end
  end

  private
  
  def pid_exists?(pid)
    Process.getpgid(pid)
  rescue Errno::ESRCH
    false
  end

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

  def local_web_url
    "http://127.0.0.1:#{ENV['UNICORN_PORT'] || 3000}/srv/status"
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
