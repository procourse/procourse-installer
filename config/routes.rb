ProcourseInstaller::Engine.routes.draw do
  get '/install' => 'install#state'
  post '/install' => 'install#install'
  get '/installed' => 'install#show'
  delete '/uninstall/:plugin_name' => 'install#uninstall'
end
