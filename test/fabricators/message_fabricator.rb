# frozen_string_literal: true

Fabricator(:message) do
  body { sequence(:body).to_s }
  mac { SecureRandom.hex }
  iv { SecureRandom.hex(8) }
  sender_user_id { Fabricator(:user).id }
  receiver_user_id { Fabricator(:user).id }
  sender_ephemeral_public_key { SecureRandom.hex }
  ephemeral_key_id_on_user_device { sequence(:number, 1) }
end
