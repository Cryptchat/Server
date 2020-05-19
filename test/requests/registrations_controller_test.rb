require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "#knock should salute you" do
    get "/knock-knock.json"
    assert_equal(200, response.status)
    json = JSON.parse(response.body)
    assert_equal(true, json["is_cryptchat"])
  end

  test "#register requires country_code and phone_number when id is absent" do
    post "/register.json", params: { phone_number: "111" }
    assert_equal(400, response.status)
    assert_includes(response.parsed_body["messages"], "param is missing or the value is empty: country_code")

    post "/register.json", params: { country_code: "111" }
    assert_equal(400, response.status)
    assert_includes(response.parsed_body["messages"], "param is missing or the value is empty: phone_number")
  end

  test "#register without id param creates a registration record" do
    post "/register.json", params: { country_code: "111", phone_number: "1111" }
    assert_equal(200, response.status)
    id = response.parsed_body["id"]
    record = Registration.find(id)
    assert_equal("1111", record.phone_number)
    assert_equal("111", record.country_code)
    assert_nil(record.user_id)
  end

  test "#register without id param doesn't create registration if number already exists on the system" do
    user = Fabricate(:user)
    Fabricate(:registration, phone_number: user.phone_number, country_code: user.country_code, user_id: user.id)

    post "/register.json", params: { country_code: user.country_code, phone_number: user.phone_number }
    assert_equal(403, response.status)
    assert_includes(response.parsed_body["messages"], I18n.t("number_already_registered"))
  end

  test "#register resets token and timestamps if record already exists but not confirmed" do
    post "/register.json", params: { country_code: "111", phone_number: "1111" }
    assert_equal(200, response.status)
    record = Registration.find(response.parsed_body["id"])

    travel(5.minutes)

    post "/register.json", params: { country_code: "111", phone_number: "1111" }
    assert_equal(200, response.status)
    new_record = Registration.find(response.parsed_body["id"])

    assert_not_equal(record.verification_token_hash, new_record.verification_token_hash)
    assert_not_equal(record.salt, new_record.salt)
    assert_equal(record.id, new_record.id)
    assert_in_delta(new_record.created_at - record.created_at, 300, 1)
    assert_nil(record.user_id)
    assert_nil(new_record.user_id)
  end

  test "#register doesn't reset token if registration is confirmed" do
    SecureRandom.stub :rand, 0.123456789123456789 do
      post "/register.json", params: { country_code: "111", phone_number: "1111" }
    end
    assert_equal(200, response.status)
    record = Registration.find(response.parsed_body["id"])
    assert_nil(record.user_id)

    post "/register.json", params: {
      id: record.id,
      verification_token: "12345679",
      identity_key: "3333aaaa"
    }
    assert_equal(200, response.status)
    record.reload
    assert(record.user)
    assert_equal(record.user.phone_number, record.phone_number)
    assert_equal(record.user.country_code, record.country_code)
    old_attrs = record.attributes

    travel(5.minutes)

    post "/register.json", params: {
      id: record.id,
      verification_token: "12345679",
      identity_key: "4444bbbb"
    }
    assert_equal(403, response.status)
    assert_includes(response.parsed_body["messages"], I18n.t("number_already_registered"))
    record.reload
    assert_equal(old_attrs, record.attributes)
  end

  test "#register doesn't confirm registration if incorrect token is provided" do
    post "/register.json", params: { country_code: "111", phone_number: "1111" }
    assert_equal(200, response.status)
    record = Registration.find(response.parsed_body["id"])
    assert_nil(record.user_id)

    post "/register.json", params: {
      id: record.id,
      verification_token: "aaaabbbb",
      identity_key: "3333aaaa"
    }
    assert_equal(403, response.status)
    assert_includes(response.parsed_body["messages"], I18n.t("incorrect_code"))
    record.reload
    assert_nil(record.user_id)
  end

  test "#register doesn't confirm registration if too much time has passed" do
    SecureRandom.stub :rand, 0.123456789123456789 do
      post "/register.json", params: { country_code: "111", phone_number: "1111" }
    end
    assert_equal(200, response.status)
    record = Registration.find(response.parsed_body["id"])
    assert_nil(record.user_id)

    travel(20.minutes)

    post "/register.json", params: {
      id: record.id,
      verification_token: "12345679",
      identity_key: "3333aaaa"
    }
    assert_equal(403, response.status)
    assert_includes(response.parsed_body["messages"], I18n.t("too_much_time_passed"))
    record.reload
    assert_nil(record.user_id)
  end
end
