module ProcourseInstaller
  class Engine < ::Rails::Engine

    isolate_namespace ProcourseInstaller

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::ProcourseInstaller::Engine, at: "/procourse-installer"
      end
    end
  end
end
