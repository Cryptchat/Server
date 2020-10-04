# frozen_string_literal: true

class UploadsController < ApplicationController
  before_action :ensure_logged_in, except: [:get_avatar, :my_avatar_url]

  def upload_avatar
    file = params[:file]
    if !file.respond_to?(:path)
      return render error_response(
        message: I18n.t("jpeg_file_required"),
        status: 422
      )
    end

    upload = Upload.create_avatar!(file.path)
    current_user.update!(avatar_id: upload.id)
    User.notify_users(excluded_user_id: current_user.id)
    render json: { avatar_id: upload.id }, status: 200
  rescue Upload::UploadsError => err
    render error_response(
      status: 422,
      message: err.message
    )
  end

  def my_avatar_url
    url = current_user&.avatar&.url
    render json: { url: url }, status: 200
  end

  def get_avatar
    upload = Upload.find_by(sha: params[:sha])

    if !upload
      return render error_response(
        status: 404,
        message: "not found"
      )
    end

    send_file(
      upload.path,
      type: "image/#{upload.extension}",
      disposition: "inline"
    )
  end
end
