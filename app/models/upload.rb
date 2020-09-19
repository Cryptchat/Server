# frozen_string_literal: true

class Upload < ApplicationRecord
  AVATARS_DIR = File.join(Rails.root, "storage", "avatars")

  class UploadsError < StandardError; end

  def path
    return @path if @path
    args = [AVATARS_DIR]
    args << "tests" if Rails.env.test?
    args << "#{self.sha}.#{self.extension}"
    @path ||= File.join(args)
  end

  def url
    "/avatar/#{self.sha}"
  end

  def self.create_avatar!(file_path)
    File.open(file_path) do |file|
      # JPEG files magic bytes
      # could probably be improved
      if file.read(4) != "\xFF\xD8\xFF\xE0".b
        raise UploadsError.new(I18n.t("incorrect_jpeg_format"))
      end
    end

    sha = Digest::SHA1.file(file_path).hexdigest
    upload = find_by(sha: sha)
    if !upload
      upload = Upload.new(
        sha: sha,
        extension: "jpeg"
      )
      upload.save!
    end
    FileUtils.cp(file_path, upload.path) unless File.exists?(upload.path)
    upload
  end
end

# == Schema Information
#
# Table name: uploads
#
#  id         :bigint           not null, primary key
#  sha        :string           not null
#  extension  :string(20)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_uploads_on_sha  (sha) UNIQUE
#
