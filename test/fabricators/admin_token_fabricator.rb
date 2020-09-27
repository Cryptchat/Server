# frozen_string_literal: true

Fabricator(:admin_token) do
  user_id { Fabricate(:user, admin: true).id }
  token { SecureRandom.hex(32) }
  last_used_at { nil }
end

# == Schema Information
#
# Table name: admin_tokens
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  token        :string           not null
#  last_used_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_admin_tokens_on_user_id  (user_id) UNIQUE
#
