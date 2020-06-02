# frozen_string_literal: true

class Message < ApplicationRecord
  validates :body,
    :mac,
    :iv,
    :sender,
    :receiver,
    presence: true
  belongs_to :sender, foreign_key: :sender_user_id, class_name: 'User'
  belongs_to :receiver, foreign_key: :receiver_user_id, class_name: 'User'
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
