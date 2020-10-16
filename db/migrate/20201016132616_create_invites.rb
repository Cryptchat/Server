# frozen_string_literal: true

class CreateInvites < ActiveRecord::Migration[6.0]
  def change
    create_table :invites do |t|
      t.bigint :inviter_id, null: false
      t.string :country_code, null: false, limit: 10
      t.string :phone_number, null: false, limit: 50
      t.datetime :expires_at, null: false
      t.boolean :claimed, null: false, default: false
      t.timestamps null: false
    end

    add_index :invites, %i[country_code phone_number], unique: true
  end
end
