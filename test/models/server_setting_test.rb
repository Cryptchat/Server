# frozen_string_literal: true

require 'test_helper'

class ServerSettingTest < ActiveSupport::TestCase
  test '.parse_yaml raises when bad type is given' do
    assert_raise(ServerSetting::UnknownType) do
      ServerSetting.parse_yaml({ setting: { default: 1, type: 'sdaa' } }.to_yaml)
    end
    assert_raise(ServerSetting::UnknownType) do
      ServerSetting.parse_yaml({ setting: [1, 2, 3] }.to_yaml)
    end
    assert_raise(ServerSetting::UnknownType) do
      ServerSetting.parse_yaml({ setting: nil }.to_yaml)
    end
  end

  test '.parse_yaml raises when there is no default value' do
    assert_raise(ServerSetting::MissingDefault) do
      ServerSetting.parse_yaml({ setting: { type: 'string' } }.to_yaml)
    end
  end

  test '.parse_yaml raises when setting name has unpermitted characters' do
    assert_raise(ServerSetting::BadName) do
      ServerSetting.parse_yaml({ "Setting": 1 }.to_yaml)
    end
    assert_raise(ServerSetting::BadName) do
      ServerSetting.parse_yaml({ "setting-asasa": 1 }.to_yaml)
    end
    assert_raise(ServerSetting::BadName) do
      ServerSetting.parse_yaml({ "setting asasa": 1 }.to_yaml)
    end
  end

  test '.parse_yaml correctly determines type and default value' do
    parsed = ServerSetting.parse_yaml(
      {
        setting1: 1,
        setting2: 3.1,
        setting3: '1',
        setting4: true,
        setting5: false,
        setting6: {
          default: 2
        },
        setting7: {
          default: 5.2
        },
        setting8: {
          default: '6'
        },
        setting9: {
          default: true
        },
        setting10: {
          default: false
        },
        setting11: {
          default: 1,
          type: 'integer'
        },
        setting12: {
          default: 1.3,
          type: 'float'
        },
        setting13: {
          default: 'dsa',
          type: 'string'
        },
        setting14: {
          default: true,
          type: 'boolean'
        },
        setting15: {
          default: false,
          type: 'boolean'
        }
      }.to_yaml
    )
    assert_equal(
      %w[setting1 setting6 setting11],
      parsed.select { |k, v| v[:type] == ServerSetting::TYPES[:integer] }.keys
    )
    assert_equal(
      %w[setting2 setting7 setting12],
      parsed.select { |k, v| v[:type] == ServerSetting::TYPES[:float] }.keys
    )
    assert_equal(
      %w[setting3 setting8 setting13],
      parsed.select { |k, v| v[:type] == ServerSetting::TYPES[:string] }.keys
    )
    assert_equal(
      %w[setting4 setting5 setting9 setting10 setting14 setting15],
      parsed.select { |k, v| v[:type] == ServerSetting::TYPES[:boolean] }.keys
    )
    assert_equal(1, parsed[:setting1][:default_value])
    assert_equal(3.1, parsed[:setting2][:default_value])
    assert_equal('1', parsed[:setting3][:default_value])
    assert_equal(true, parsed[:setting4][:default_value])
    assert_equal(false, parsed[:setting5][:default_value])
    assert_equal(2, parsed[:setting6][:default_value])
    assert_equal(5.2, parsed[:setting7][:default_value])
    assert_equal('6', parsed[:setting8][:default_value])
    assert_equal(true, parsed[:setting9][:default_value])
    assert_equal(false, parsed[:setting10][:default_value])
    assert_equal(1, parsed[:setting11][:default_value])
    assert_equal(1.3, parsed[:setting12][:default_value])
    assert_equal('dsa', parsed[:setting13][:default_value])
    assert_equal(true, parsed[:setting14][:default_value])
    assert_equal(false, parsed[:setting15][:default_value])
  end

  test '.all_settings returns all settings with correct metadata' do
    ServerSetting.create!(
      name: 'setting_that_no_longer_exists',
      value: '11111',
      data_type: ServerSetting::TYPES[:string]
    )
    all_settings = ServerSetting.all_settings
    assert_nil(all_settings.find { |s| s.name == 'setting_that_no_longer_exists' })
    refute(all_settings.find { |s| s.name == 'server_name' }.overriden)
    assert_equal('string', all_settings.find { |s| s.name == 'server_name' }.partial)
    assert_equal('server name', all_settings.find { |s| s.name == 'server_name' }.display_name)
    assert_equal('Cryptchat Server', all_settings.find { |s| s.name == 'server_name' }.value)

    ServerSetting.server_name = 'my test server'
    all_settings = ServerSetting.all_settings
    assert(all_settings.find { |s| s.name == 'server_name' }.overriden)
    assert_equal('string', all_settings.find { |s| s.name == 'server_name' }.partial)
    assert_equal('my test server', all_settings.find { |s| s.name == 'server_name' }.value)

    ServerSetting.server_name = 'Cryptchat Server'
    all_settings = ServerSetting.all_settings
    refute(all_settings.find { |s| s.name == 'server_name' }.overriden)
    assert_equal('string', all_settings.find { |s| s.name == 'server_name' }.partial)
    assert_equal('Cryptchat Server', all_settings.find { |s| s.name == 'server_name' }.value)
  end

  test '.defaults holds default values' do
    assert_equal('Cryptchat Server', ServerSetting.defaults[:server_name][:value])
    ServerSetting.server_name = 'my test server'
    assert_equal('Cryptchat Server', ServerSetting.defaults[:server_name][:value])
  end
end

# == Schema Information
#
# Table name: server_settings
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  value      :text
#  data_type  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_server_settings_on_name  (name) UNIQUE
#
