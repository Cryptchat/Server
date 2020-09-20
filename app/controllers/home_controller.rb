# frozen_string_literal: true

class HomeController < ApplicationController
  def home
    render plain: "Cryptchat server", status: 200
  end
end
