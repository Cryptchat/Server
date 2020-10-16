# frozen_string_literal: true

class ServerSetting < ApplicationRecord
  class UnknownType < StandardError; end
  class MissingDefault < StandardError; end
  class BadName < StandardError; end
  class DuplicateName < StandardError; end

  SettingStruct = Struct.new(
    :name,
    :display_name,
    :value,
    :overriden,
    :partial,
    :description
  )

  TYPES = {
    string: 1,
    integer: 2,
    float: 3,
    boolean: 4
  }

  class << self
    def all_settings
      settings = []
      where(name: ServerSetting.defaults.keys).each do |setting|
        normalized = normalize(setting.value, setting.data_type)
        overriden = normalized != defaults[setting.name][:value]
        settings << SettingStruct.new(
          setting.name,
          display_name(setting.name),
          normalized,
          overriden,
          partial_for_type(setting.data_type),
          I18n.t("admin.server_settings.#{setting.name}")
        )
      end
      ServerSetting.defaults.each do |name, hash|
        next if settings.any? { |s| s.name == name.to_s }
        settings << SettingStruct.new(
          name.to_s,
          display_name(name.to_s),
          hash[:value],
          false,
          partial_for_type(hash[:type]),
          I18n.t("admin.server_settings.#{name}")
        )
      end
      settings.sort_by! { |s| s.name }
      settings
    end

    def defaults
      raise "server settings have not been initialized" unless instance_variable_defined?(:@defaults)
      @defaults
    end

    def load_settings(file)
      @defaults = HashWithIndifferentAccess.new
      parse_yaml(File.read(file)).each do |name, hash|
        raise DuplicateName.new(name) if respond_to?(name)
        type = hash[:type]
        default_value = hash[:default_value]
        define_methods(name, type, default_value)
        @defaults[name] = { value: default_value, type: type }
      end
    end

    def parse_yaml(yaml)
      raw_settings = YAML.safe_load(yaml, [Symbol])
      raw_settings.deep_symbolize_keys!
      settings = HashWithIndifferentAccess.new
      raw_settings.each do |name, value|
        if Hash === value
          type = value[:type] ? TYPES[value[:type].to_s.to_sym] : guess_type(value[:default])
          default_value = value[:default]
        else
          type = guess_type(value)
          default_value = value
        end
        raise UnknownType.new(name) if !type
        raise MissingDefault.new(name) if default_value.nil?
        raise BadName.new(name) if !name.match?(/^[a-z0-9_]+$/)
        settings[name] = {
          type: type,
          default_value: default_value
        }
      end
      settings
    end

    private

    def normalize(value, type)
      if type == TYPES[:string]
        value.to_s
      elsif type == TYPES[:integer]
        value.to_i
      elsif type == TYPES[:float]
        value.to_f
      elsif type == TYPES[:boolean]
        value.to_s.downcase == 'true'
      end
    end

    def display_name(name)
      name.gsub('_', ' ')
    end

    def partial_for_type(type)
      if type == ServerSetting::TYPES[:string]
        "string"
      elsif type == ServerSetting::TYPES[:integer]
        "number"
      elsif type == ServerSetting::TYPES[:float]
        "number"
      elsif type == ServerSetting::TYPES[:boolean]
        "boolean"
      end
    end

    def guess_type(value)
      if String === value
        TYPES[:string]
      elsif Integer === value
        TYPES[:integer]
      elsif Float === value
        TYPES[:float]
      elsif TrueClass === value || FalseClass === value
        TYPES[:boolean]
      end
    end

    def define_methods(name, type, default_value)
      self.define_singleton_method(name) do
        record = ServerSetting.where(name: name).first
        value = record ? record.value : default_value
        normalize(value, type)
      end

      self.define_singleton_method("#{name}=") do |new_val|
        record = ServerSetting.where(name: name).first || ServerSetting.new(name: name, data_type: type)
        record.value = normalize(new_val, type).to_s
        record.save!
        new_val
      end
    end
  end

  load_settings(File.join(Rails.root, "config", "settings.yml"))

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
