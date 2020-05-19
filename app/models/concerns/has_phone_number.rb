module HasPhoneNumber
  extend ActiveSupport::Concern

  included do
    %i[country_code phone_number].each do |col|
      validates col, presence: true
    end
    validates :phone_number, uniqueness: { scope: :country_code }
    validates :phone_number, length: { maximum: 50 }
    validates :country_code, length: { maximum: 10 }
  end
end
