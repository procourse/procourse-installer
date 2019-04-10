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
end

load File.expand_path('../lib/procourse_installer/engine.rb', __FILE__)
load File.expand_path('../lib/procourse_installer/installed_plugins.rb', __FILE__)

after_initialize do
  require_dependency File.expand_path('../app/jobs/regular/procourse_installer_upgrade_plugin.rb', __FILE__)
end
