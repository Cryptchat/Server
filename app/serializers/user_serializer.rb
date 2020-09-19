# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :country_code,
    :phone_number,
    :identity_key,
    :updated_at,
    :created_at,
    :avatar_url
  )

  def updated_at
    (object.updated_at.to_f * 1000).floor
  end

  def created_at
    (object.created_at.to_f * 1000).floor
  end

  def avatar_url
    object.avatar&.url
  end
end

# == Schema Information
#
# Table name: users
#
#  id           :bigint           not null, primary key
#  name         :string(255)
#  country_code :string(10)       not null
#  phone_number :string(50)       not null
#  instance_id  :string
#  identity_key :string           not null
#  avatar_id    :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_users_on_country_code_and_phone_number  (country_code,phone_number) UNIQUE
#  index_users_on_identity_key                   (identity_key) UNIQUE
#  index_users_on_instance_id                    (instance_id) UNIQUE
#
