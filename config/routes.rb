ProcourseInstaller::Engine.routes.draw do
  post '/install' => 'install#install'
end
