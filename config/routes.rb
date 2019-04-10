ProcourseInstaller::Engine.routes.draw do
  post '/install' => 'install#install'
  get '/installed' => 'install#show'
end
