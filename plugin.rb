# name: procourse-installer
# about: A Discourse plugin for discovering and installing other Discourse plugins.
# version: 0.1
# authors: ProCourse
# url: https://github.com/procourse/procourse-installer


register_asset 'stylesheets/procourse-installer.scss'
add_admin_route 'procourse_installer.title', 'procourse-installer'

#Adding butler admin page
Discourse::Application.routes.append do
  get '/admin/plugins/procourse-installer' => 'admin/plugins#index'
  get '/admin/plugins/procourse-installer/installed' => 'admin/plugins#index'
end

load File.expand_path('../lib/procourse_installer/engine.rb', __FILE__)
load File.expand_path('../lib/procourse_installer/installed_plugins.rb', __FILE__)

after_initialize do
  require_dependency File.expand_path('../app/jobs/regular/procourse_installer_upgrade_plugin.rb', __FILE__)

  module ::DockerManager
    class Upgrader
      module RemovePlugin
        def remove(plugin_to_remove)
          percent(0)

          clear_logs

          log("********************************************************")
          log("*** Please be patient, next steps might take a while ***")
          log("********************************************************")

          launcher_pid = unicorn_launcher_pid
          master_pid = unicorn_master_pid
          workers = unicorn_workers(master_pid).size

          if workers < 2
            log("ABORTING, you do not have enough unicorn workers running")
            raise "Not enough workers"
          end

          if launcher_pid <= 0 || master_pid <= 0
            log("ABORTING, missing unicorn launcher or unicorn master")
            raise "No unicorn master or launcher"
          end

          log("Cycling Unicorn, to free up memory")
          reload_unicorn(launcher_pid)

          percent(10)
          reloaded = false
          num_workers_spun_down = workers - min_workers

          if num_workers_spun_down.positive?
            log "Stopping #{workers - min_workers} Unicorn worker(s), to free up memory"
            (num_workers_spun_down).times { Process.kill("TTOU", unicorn_master_pid) }
          end

          if ENV["UNICORN_SIDEKIQS"].to_i > 0
            log "Stopping job queue to reclaim memory, master pid is #{master_pid}"
            Process.kill("TSTP", unicorn_master_pid)
            sleep 1
            # older versions do not have support, so quickly send a cont so master process is not hung
            Process.kill("CONT", unicorn_master_pid)
          end

          run("cd /var/www/discourse/plugins && rm -rf #{plugin_to_remove[:name]}")
          percent(20)
          log("Removed plugin source directory")

          run("bundle install --deployment --without test --without development")
          percent(30)
          run("SKIP_POST_DEPLOYMENT_MIGRATIONS=1 bundle exec rake multisite:migrate")
          percent(40)
          log("*** Bundling assets. This will take a while *** ")
          less_memory_flags = "RUBY_GC_MALLOC_LIMIT_MAX=20971520 RUBY_GC_OLDMALLOC_LIMIT_MAX=20971520 RUBY_GC_HEAP_GROWTH_MAX_SLOTS=50000 RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=0.9 "
          run("#{less_memory_flags} bundle exec rake assets:precompile")

          percent(80)
          reload_unicorn(launcher_pid)
          reloaded = true

          percent(90)
          log("Running post deploy migrations")
          run("bundle exec rake multisite:migrate")
          log_version_upgrade
          percent(100)
          log("DONE")
          publish('status', 'complete')
        rescue => ex
          publish('status', 'failed')

          [
            "Docker Manager: FAILED TO REMOVE",
            ex.inspect,
            ex.backtrace.join("\n"),
          ].each do |message|

            STDERR.puts(message)
            log(message)
          end

          if num_workers_spun_down.positive? && !reloaded
            log "Spinning up #{num_workers_spun_down} Unicorn worker(s) that were stopped initially"
            (num_workers_spun_down).times { Process.kill("TTIN", unicorn_master_pid) }
          end

          raise ex
        end
      end
      prepend RemovePlugin
    end
  end
end
