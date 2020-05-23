# frozen_string_literal: true
module HasPhoneNumberTest
  extend ActiveSupport::Concern

  included do
    # puts methods.select { |m| m =~ /class/ }.join(', ')
    klass = self.name.gsub(/Test$/, '').constantize
    test "phone_number and country_code must be present" do
      record = klass.new
      record.save
      assert_includes(record.errors.full_messages, "Country code can't be blank")
      assert_includes(record.errors.full_messages, "Phone number can't be blank")
    end

    test "phone_number and country_code combined must be unique" do
      record_a = Fabricate(klass.name.downcase.to_sym)
      record_b = Fabricate(klass.name.downcase.to_sym)
      assert(record_a.valid?)
      assert(record_b.valid?)

      record_a.country_code = record_b.country_code = "966"
      record_a.phone_number = record_b.phone_number = "501234567"
      record_a.save!
      record_b.save
      assert_includes(record_b.errors.full_messages, "Phone number has already been taken")
      record_b.country_code = "965"
      record_b.save!
    end
  end
end
