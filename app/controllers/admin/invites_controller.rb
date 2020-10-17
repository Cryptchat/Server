# frozen_string_literal: true

class Admin::InvitesController < Admin::AdminController
  def index
    @invites = Invite.all
  end

  def create
    country_id = params[:country]&.strip
    phone_number = params[:phone_number]&.strip
    if country_id.blank? || phone_number.blank?
      return redirect_to :admin_invites, flash: { error: t('.empty_country_code_or_number') }
    end
    phone_number = phone_number.gsub(/[^\d]/, '')
    country = Countries.from_id(country_id)
    if !country
      return redirect_to :admin_invites, flash: { error: t('.not_allowed_country') }
    end
    if !Countries.valid_number?(country_id, phone_number)
      return redirect_to :admin_invites, flash: { error: t('.invalid_number') }
    end
    country_code = country[:country_code]
    begin
      Invite.invite!(current_admin, country_code, phone_number)
    rescue Invite::InviteError => error
      return redirect_to :admin_invites, flash: { error: t(".#{error.message}") }
    end
    redirect_to :admin_invites, notice: t('.invite_success', number: country_code + phone_number)
  end
end
