Automation::Engine.routes.draw do
  resources :nodes, only: %i[index show update destroy] do
    get "install", on: :collection
    post "show_instructions", on: :collection
    get "run_automation", on: :collection
  end

  resources :jobs, only: [:show] do
    get ":id/show_payload",
        to: "jobs#show_data",
        defaults: {
          attr: "payload",
        },
        on: :collection,
        as: "show_payload"
    get ":id/show_log",
        to: "jobs#show_data",
        defaults: {
          attr: "log",
        },
        on: :collection,
        as: "show_log"
  end

  resources :automations, only: %i[index new create show edit update destroy] do
    get "index_update_runs", on: :collection
  end

  resources :runs, only: [:show] do
    get ":id/show_log/",
        to: "runs#show_log",
        on: :collection,
        as: "show_payload"
  end
end
