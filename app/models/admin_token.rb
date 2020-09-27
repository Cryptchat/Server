# frozen_string_literal: true

class AdminToken < ApplicationRecord
  validates :user_id, uniqueness: true
  attr_accessor :unhashed_token
  belongs_to :user

  def self.create_for!(user)
    where(user_id: user.id).destroy_all
    record = self.new
    record.user_id = user.id
    unhashed_token = SecureRandom.hex(32)
    record.token = hash_key(unhashed_token)
    record.last_used_at = nil
    record.save!
    record.unhashed_token = unhashed_token
    record
  end

  def self.hash_key(key)
    Digest::SHA256.hexdigest(key)
  end

  def self.lookup_admin(token, id)
    hashed = hash_key(token)
    user = AdminToken.where(user_id: id, token: hashed).first&.user
    user&.admin? ? user : nil
  end
end

# == Schema Information
#
# Table name: admin_tokens
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  token        :string           not null
#  last_used_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_admin_tokens_on_user_id  (user_id) UNIQUE
#
