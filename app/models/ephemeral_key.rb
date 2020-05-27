# frozen_string_literal: true
class EphemeralKey < ApplicationRecord
  belongs_to :user
end

# == Schema Information
#
# Table name: ephemeral_keys
#
#  id                :bigint           not null, primary key
#  key               :string           not null
#  id_on_user_device :bigint           not null
#  user_id           :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_ephemeral_keys_on_user_id  (user_id)
#
