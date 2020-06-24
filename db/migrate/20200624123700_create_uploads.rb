# frozen_string_literal: true

class CreateUploads < ActiveRecord::Migration[6.0]
  def change
    create_table :uploads do |t|
      t.string :sha, null: false
      t.string :extension, null: false, limit: 20

      t.timestamps
    end

    add_index :uploads, :sha, unique: true
  end
end
