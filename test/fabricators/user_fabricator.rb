# frozen_string_literal: true

Fabricator(:user) do
  country_code "+966"
  phone_number { sequence(:phone_number).to_s }
  instance_id { sequence(:instance_id).to_s }
  identity_key { sequence(:identity_key).to_s }
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
#  admin        :boolean          default("false"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  suspended    :boolean          default("false"), not null
#
# Indexes
#
#  index_users_on_country_code_and_phone_number  (country_code,phone_number) UNIQUE
#  index_users_on_identity_key                   (identity_key) UNIQUE
#  index_users_on_instance_id                    (instance_id) UNIQUE
#
