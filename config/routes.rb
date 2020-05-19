Rails.application.routes.draw do
  scope path: nil, constraints: { format: :json } do
    post "message.json" => "messages#transmit"
    put "user/:id.json" => "users#update"
    get "knock-knock.json" => "registrations#knock"
    post "register.json" => "registrations#register"
  end
end
