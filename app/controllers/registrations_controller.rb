class RegistrationsController < ApplicationController
  def knock
    render json: {
      is_sechat: true,
      name: "Smokin' hot!"
    }
  end

  def register
    if params[:id]
      verification_token, identity_key = params.require([:verification_token, :identity_key])
      record = Registration.find_by(id: params[:id])
      return render json: {}, status: 404 unless record

      result = record.verify(verification_token)
      if result[:success]
        user = User.new(
          country_code: record.country_code,
          phone_number: record.phone_number,
          identity_key: identity_key
        )

        ActiveRecord::Base.transaction do
          user.save!
          record.user_id = user.id
          record.save!
        end
        render json: { id: user.id }
      else
        render json: { messages: [result[:reason]] }, status: 403
      end
    else
      country_code, phone_number = params.require([:country_code, :phone_number])
      record = Registration.find_or_initialize_by(country_code: country_code, phone_number: phone_number)
      if record && record.user_id.present?
        return render json: { messages: [I18n.t("number_already_registered")] }, status: 403
      end
      record.generate_token!
      puts record.verification_token unless Rails.env.test?
      #### send SMS message here ####
      render json: { id: record.id }
    end
  end
end
