# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#home"
  scope path: nil, constraints: { format: :json } do
    post "message.json" => "messages#transmit"
    put "users.json" => "users#update"
    get "knock-knock.json" => "registrations#knock"
    post "register.json" => "registrations#register"

    post "ephemeral-keys.json" => "ephemeral_keys#top_up"
    post "ephemeral-keys/grab.json" => "ephemeral_keys#grab"

    post "sync/users.json" => "users#sync"
    post "sync/messages.json" => "messages#sync"
    post "avatar.json" => "uploads#upload_avatar"
    get "avatar/:sha" => "uploads#get_avatar"
  end
end
