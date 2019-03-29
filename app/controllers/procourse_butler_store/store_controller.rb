module ProcourseButlerStore
  class StoreController < ApplicationController

    def install
      if params[:plugin_url]
        if params[:plugin_url].end_with? ".git"
          plugin_url = params[:plugin_url]
        else
          plugin_url = params[:plugin_url] + ".git"
        end
        
        `cd /var/www/discourse/plugins && git clone #{plugin_url}`
        
        dir = plugin_url.match(/([^\/]+)\/?$/)[0][0..-5]

        repo = DockerManager::GitRepo.find('/var/www/discourse/plugins/' + dir)
        repo.stop_upgrading

        upgrader = DockerManager::Upgrader.new(-1,repo,nil)
        upgrader.upgrade
        
        render json: success_json
      else

      end
    end

  end
end
