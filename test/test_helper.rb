# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'fabrication'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/mock'
require 'webmock/minitest'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)
  parallelize(workers: 1)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end

module CryptchatIntegrationSessionPatch
  def process(method, path, **hash)
    if user_id = Thread.current[:cryptchat_sign_in_user_id]
      hash ||= {}
      headers = {
        CurrentUserImplementer::TEST_USER_AUTH_TOKEN_HEADER => user_id
      }
      if hash["headers"]
        hash["headers"].merge!(headers)
      else
        hash[:headers]&.merge!(headers) || hash[:headers] = headers
      end
      super(method, path, **hash)
    else
      super
    end
  end
end

ActionDispatch::Integration::Session.prepend(CryptchatIntegrationSessionPatch)

class ActionDispatch::IntegrationTest
  def with_user_signed_in(user)
    Thread.current[:cryptchat_sign_in_user_id] = user.id
    yield
  ensure
    Thread.current[:cryptchat_sign_in_user_id] = nil
  end
end
