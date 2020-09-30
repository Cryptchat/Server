# frozen_string_literal: true

class CreateServerSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :server_settings do |t|
      t.string :name, null: false
      t.text :value
      t.integer :data_type, null: false
      t.timestamps null: false
    end
    add_index :server_settings, :name, unique: true
  end
end
