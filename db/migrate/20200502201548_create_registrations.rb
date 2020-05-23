# frozen_string_literal: true
class CreateRegistrations < ActiveRecord::Migration[6.0]
  def change
    create_table :registrations do |t|
      t.string :verification_token_hash, limit: 64, null: false
      t.string :salt, limit: 32, null: false
      t.string :country_code, null: false, limit: 10
      t.string :phone_number, null: false, limit: 50
      t.bigint :user_id

      t.timestamps null: false
    end
    add_index :registrations, %i{country_code phone_number}, unique: true
  end
end
