# frozen_string_literal: true
class CreateEphemeralKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :ephemeral_keys do |t|
      t.string :key, null: false
      t.bigint :user_id, null: false
      t.timestamps null: false
    end
    add_index :ephemeral_keys, :user_id
  end
end
