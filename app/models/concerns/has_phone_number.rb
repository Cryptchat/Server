# frozen_string_literal: true
module HasPhoneNumber
  extend ActiveSupport::Concern

  included do
    %i[country_code phone_number].each do |col|
      validates col, presence: true
    end
    validates :phone_number, uniqueness: { scope: :country_code } if !@skip_number_uniqueness
    validates :phone_number, length: { maximum: 50 }
    validates :country_code, length: { maximum: 10 }
  end
end
