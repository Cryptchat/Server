# frozen_string_literal: true

class Admin::ServerSettingsController < Admin::AdminController
  def index
    @settings = ServerSetting.all_settings
  end

  def update
    name = params[:name]
    if params[:perform] == 'save'
      if ServerSetting.defaults.key?(name)
        ServerSetting.public_send("#{name}=", params[:value])
        redirect_to :admin_settings
      end
    elsif params[:perform] == 'revert'
      ServerSetting.find_by(name: name)&.destroy!
      redirect_to :admin_settings
    end
  end
end
