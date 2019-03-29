# name: procourse-butler
# about: A Discourse plugin for discovering and installing other Discourse plugins.
# version: 0.1
# authors: ProCourse
# url: https://github.com/procourse/procourse-butler


register_asset 'stylesheets/procourse-butler.scss'
add_admin_route 'procourse_butler.title', 'procourse-butler'

#Adding butler admin page
Discourse::Application.routes.append do
  get '/admin/plugins/procourse-butler' => 'admin/plugins#index'
end

load File.expand_path('../lib/procourse_butler_store/engine.rb', __FILE__)

after_initialize do
  require_dependency File.expand_path('../app/jobs/regular/butler_store_upgrade_plugin.rb', __FILE__)
end
