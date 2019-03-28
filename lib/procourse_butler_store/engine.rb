module ProcourseButlerStore
  class Engine < ::Rails::Engine

    isolate_namespace ProcourseButlerStore

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::ProcourseButlerStore::Engine, at: "/butler-store"
      end
    end
  end
end
