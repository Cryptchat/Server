# frozen_string_literal: true

class CreateAuthTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :auth_tokens do |t|
      t.string :auth_token, null: false
      t.string :previous_auth_token, null: false
      t.bigint :user_id, null: false
      t.datetime :rotated_at, null: false
      t.boolean :seen, null: false, default: false

      t.timestamps null: false
    end

    add_index :auth_tokens, :auth_token, unique: true
    add_index :auth_tokens, :previous_auth_token, unique: true
    add_index :auth_tokens, :user_id
  end
end
