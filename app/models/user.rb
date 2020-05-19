class User < ApplicationRecord
  include HasPhoneNumber

  has_many :received_messages, foreign_key: :receiver_user_id, class_name: 'Message'
  has_many :sent_messages, foreign_key: :sender_user_id, class_name: 'Message'

  has_one :registration

  validates :name, length: { maximum: 255 }
end

# == Schema Information
#
# Table name: users
#
#  id           :bigint           not null, primary key
#  name         :string(255)
#  country_code :string(10)       not null
#  phone_number :string(50)       not null
#  instance_id  :string
#  identity_key :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_users_on_country_code_and_phone_number  (country_code,phone_number) UNIQUE
#  index_users_on_identity_key                   (identity_key) UNIQUE
#  index_users_on_instance_id                    (instance_id) UNIQUE
#
