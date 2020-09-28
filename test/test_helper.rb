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

  private

  def stub_firebase(receivers, data:)
    receivers = [receivers] unless Array === receivers
    stub_request(:post, Notifier::FIREBASE_API_URI.to_s).with(
      body: {
        registration_ids: receivers.map(&:instance_id),
        data: data
      }.to_json,
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "key=someserverkeygoesinheretestenv" # From Rails.configuration.firebase[:server_key]
      }
    )
  end

  def cleanup_avatars_dir
    files = Dir.glob(Rails.root.join('storage', 'avatars', 'tests', '*'))
    FileUtils.rm_rf(files)
  end
end

module CryptchatIntegrationSessionPatch
  def process(method, path, **hash)
    orig_headers = hash["headers"] || hash[:headers] || (hash[:headers] = {})
    if user = User.find_by(id: Thread.current[:cryptchat_sign_in_user_id])
      token = AuthToken.generate(user)
      hash ||= {}
      headers = {
        CurrentUserImplementer::AUTH_USER_ID_HEADER => user.id,
        CurrentUserImplementer::AUTH_TOKEN_HEADER => token.unhashed_token
      }
      orig_headers.merge!(headers)
      super(method, path, **hash)
    elsif admin = User.find_by(id: Thread.current[:cryptchat_sign_in_admin_id])
      token = AdminToken.create_for!(admin)
      hash ||= {}
      headers = {
        Admin::AdminController::ADMIN_TOKEN_HEADER => token.unhashed_token,
        Admin::AdminController::ADMIN_ID_HEADER => admin.id
      }
      orig_headers.merge!(headers)
      super(method, path, **hash)
    else
      super
    end
  end
end

ActionDispatch::Integration::Session.prepend(CryptchatIntegrationSessionPatch)

class CryptchatIntegrationTest < ActionDispatch::IntegrationTest
  def sign_in(user = Fabricate(:user))
    Thread.current[:cryptchat_sign_in_user_id] = user.id
    user
  end

  def sign_out
    Thread.current[:cryptchat_sign_in_user_id] = nil
  end

  def sign_admin_in(admin)
    Thread.current[:cryptchat_sign_in_admin_id] = admin.id
  end

  def sign_admin_out
    Thread.current[:cryptchat_sign_in_admin_id] = nil
  end

  def before_setup
    sign_out
    sign_admin_out
    super
  end
end
