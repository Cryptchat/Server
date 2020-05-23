# frozen_string_literal: true
Fabricator(:registration) do
  country_code { sequence(:country_code).to_s }
  phone_number { sequence(:phone_number).to_s }
  verification_token_hash { SecureRandom.hex(32) }
  salt { SecureRandom.hex(16) }
end

# == Schema Information
#
# Table name: registrations
#
#  id                      :bigint           not null, primary key
#  verification_token_hash :string(64)       not null
#  salt                    :string(32)       not null
#  country_code            :string(10)       not null
#  phone_number            :string(50)       not null
#  user_id                 :bigint
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_registrations_on_country_code_and_phone_number  (country_code,phone_number) UNIQUE
#
