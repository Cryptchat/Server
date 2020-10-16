# frozen_string_literal: true

Fabricator(:invite) do
  inviter_id { Fabricate(:user, admin: true).id }
  country_code "+966"
  phone_number { sequence(:phone_number).to_s }
  claimed false
  expires_at 5.minutes.from_now
end
