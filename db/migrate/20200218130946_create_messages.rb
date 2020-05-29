# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.text :body, null: false
      t.text :mac, null: false
      t.text :iv, null: false
      t.bigint :sender_user_id, null: false
      t.bigint :receiver_user_id, null: false
      t.text :sender_ephemeral_public_key
      t.bigint :ephemeral_key_id_on_user_device

      t.timestamps null: false
    end
  end
end
