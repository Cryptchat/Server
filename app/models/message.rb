# frozen_string_literal: true
class Message < ApplicationRecord
  validates :body, :sender_user_id, :receiver_user_id, presence: true
  belongs_to :sender, foreign_key: :sender_user_id, class_name: 'User'
  belongs_to :receiver, foreign_key: :receiver_user_id, class_name: 'User'
end

# == Schema Information
#
# Table name: messages
#
#  id               :bigint           not null, primary key
#  body             :text             not null
#  sender_user_id   :bigint           not null
#  receiver_user_id :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
