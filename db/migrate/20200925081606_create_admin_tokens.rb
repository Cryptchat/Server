# frozen_string_literal: true

class CreateAdminTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_tokens do |t|
      t.bigint :user_id, null: false
      t.string :token, null: false
      t.datetime :last_used_at

      t.timestamps null: false
    end
    add_index :admin_tokens, :user_id, unique: true
  end
end
