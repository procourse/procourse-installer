module ProcourseButlerStore
  class StoreController < ApplicationController

    def install
      if params[:plugin_url]
        `cd /var/www/discourse/plugins && git clone #{params[:plugin_url]}.git`
        render json: success_json
      else

      end
    end

  end
end
