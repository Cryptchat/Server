# frozen_string_literal: true

class EphemeralKeySerializer < ActiveModel::Serializer
  attributes :id_on_user_device, :key
end
