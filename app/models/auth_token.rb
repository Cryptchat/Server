# frozen_string_literal: true

class AuthToken < ApplicationRecord
  belongs_to :user
  attr_accessor :unhashed_token

  class << self
    def generate(user)
      token = SecureRandom.hex
      hashed_token = hash_token(token)
      record = AuthToken.create!(
        auth_token: hashed_token,
        previous_auth_token: hashed_token,
        user_id: user.id,
        rotated_at: Time.zone.now,
        seen: false
      )
      record.unhashed_token = token
      record
    end

    def lookup(unhashed_token, user_id)
      return if !unhashed_token ||
        unhashed_token.size != 32 ||
        !user_id ||
        user_id <= 0

      hashed_token = hash_token(unhashed_token)
      record = AuthToken.find_by(
        "user_id = :user_id AND (auth_token = :token OR previous_auth_token = :token)",
        token: hashed_token,
        user_id: user_id
      )
      return unless record

      if !record.seen && record.auth_token == hashed_token
        updated_rows = AuthToken
          .where(id: record.id, auth_token: hashed_token)
          .update_all(seen: true)

        if updated_rows > 0
          record.seen = true
        end
      end
      record
    end

    def hash_token(token)
      Digest::SHA1.base64digest(token)
    end
  end

  def rotate
    token = SecureRandom.hex
    hashed_token = AuthToken.hash_token(token)
    args = {
      new_token: hashed_token,
      now: Time.zone.now,
      record_id: self.id,
      safeguard: 30.seconds.ago
    }
    query = ActiveRecord::Base.sanitize_sql_array([<<~SQL, args])
      UPDATE auth_tokens
      SET
        previous_auth_token = CASE WHEN seen THEN auth_token ELSE previous_auth_token END,
        auth_token = :new_token,
        rotated_at = :now,
        seen = false
      WHERE id = :record_id AND rotated_at < :safeguard
    SQL
    updated_rows = self.class.connection.execute(query)&.cmd_tuples
    if updated_rows && updated_rows > 0
      self.reload
      self.unhashed_token = token
      true
    else
      false
    end
  end
end

# == Schema Information
#
# Table name: auth_tokens
#
#  id                  :bigint           not null, primary key
#  auth_token          :string           not null
#  previous_auth_token :string           not null
#  user_id             :bigint           not null
#  rotated_at          :datetime         not null
#  seen                :boolean          default("false"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_auth_tokens_on_auth_token           (auth_token) UNIQUE
#  index_auth_tokens_on_previous_auth_token  (previous_auth_token) UNIQUE
#  index_auth_tokens_on_user_id              (user_id)
#
