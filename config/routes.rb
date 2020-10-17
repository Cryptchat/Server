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
    get "my-avatar.json" => "uploads#my_avatar_url"
    post "generate-admin-token.json" => "admin_tokens#generate"
  end
  namespace :admin do
    get '' => 'admin#index'
    resources :users, only: %i[index] do
      put 'suspend'
      put 'unsuspend'
      put 'grant-admin'
      put 'revoke-admin'
    end

    get 'settings' => 'server_settings#index'
    put 'settings/:name' => 'server_settings#update'
    get 'invites' => 'invites#index'
    post 'invites' => 'invites#create'
  end
end
