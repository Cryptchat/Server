# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < CryptchatIntegrationTest
  test '#include_cryptchat_headers adds remaining ephemeral keys count for logged in users' do
    user = Fabricate(:user)
    sign_in(user)
    get '/'
    assert_equal(0, response.headers[ApplicationController::REMAINING_KEYS_COUNT_HEADER])
    3.times { Fabricate(:ephemeral_key, user_id: user.id) }
    get '/'
    assert_equal(3, response.headers[ApplicationController::REMAINING_KEYS_COUNT_HEADER])
  end

  test '#include_cryptchat_headers does not add headers for anon requests' do
    get '/'
    refute(response.headers.key?(ApplicationController::REMAINING_KEYS_COUNT_HEADER))
  end

  test 'does not allow suspended users to perform any action' do
    user = Fabricate(:user, suspended: true)
    sign_in(user)
    get '/'
    assert_equal(403, response.status)
    assert_equal(I18n.t('you_are_suspended'), response.parsed_body['messages'].first)
  end
end
