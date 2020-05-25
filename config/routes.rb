# frozen_string_literal: true

Rails.application.routes.draw do
  scope path: nil, constraints: { format: :json } do
    post "message.json" => "messages#transmit"
    put "user/:id.json" => "users#update"
    get "knock-knock.json" => "registrations#knock"
    post "register.json" => "registrations#register"

    post "ephemeral-keys.json" => "ephemeral_keys#top_up"

    get "sync/users.json" => "users#sync"
  end
end
