# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :country_code,
    :phone_number,
    :identity_key,
    :updated_at,
    :created_at
  )

  def updated_at
    object.updated_at.to_f
  end

  def created_at
    object.created_at.to_f
  end
end
