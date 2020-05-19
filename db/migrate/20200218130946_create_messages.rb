class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.text :body, null: false
      t.bigint :sender_user_id, null: false 
      t.bigint :receiver_user_id, null: false 

      t.timestamps null: false
    end
  end
end
