module Jobs
  class ButlerStoreUpgradePlugin < Jobs::Base
    def execute(args)
      repo = DockerManager::GitRepo.new('/var/www/discourse/plugins/' + args[:dir], args[:dir])
      repo.stop_upgrading

      upgrader = DockerManager::Upgrader.new(args[:user_id],repo,nil)
      upgrader.upgrade
    end
  end
end
