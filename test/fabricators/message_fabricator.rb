# frozen_string_literal: true

Fabricator(:message) do
  body { sequence(:body).to_s }
  mac { SecureRandom.hex }
  iv { SecureRandom.hex(8) }
  sender_user_id { Fabricate(:user).id }
  receiver_user_id { Fabricate(:user).id }
  sender_ephemeral_public_key { SecureRandom.hex }
  ephemeral_key_id_on_user_device { sequence(:number, 1) }
end

# == Schema Information
#
# Table name: messages
#
#  id                              :bigint           not null, primary key
#  body                            :text             not null
#  mac                             :text             not null
#  iv                              :text             not null
#  sender_user_id                  :bigint           not null
#  receiver_user_id                :bigint           not null
#  sender_ephemeral_public_key     :text
#  ephemeral_key_id_on_user_device :bigint
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
