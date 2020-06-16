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

    def lookup(unhashed_token)
      return if !unhashed_token || unhashed_token.size != 32

      hashed_token = hash_token(unhashed_token)
      record = AuthToken.find_by("auth_token = :token OR previous_auth_token = :token", token: hashed_token)
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
