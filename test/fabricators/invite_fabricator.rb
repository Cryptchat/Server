# frozen_string_literal: true

Fabricator(:invite) do
  inviter_id { Fabricate(:user, admin: true).id }
  country_code "+966"
  phone_number { sequence(:phone_number).to_s }
  claimed false
  expires_at 5.minutes.from_now
end

# == Schema Information
#
# Table name: invites
#
#  id           :bigint           not null, primary key
#  inviter_id   :bigint           not null
#  country_code :string(10)       not null
#  phone_number :string(50)       not null
#  expires_at   :datetime         not null
#  claimed      :boolean          default("false"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
