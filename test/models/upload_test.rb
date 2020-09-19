# frozen_string_literal: true

require 'test_helper'

class UploadTest < ActiveSupport::TestCase
  test '.create_avatar! raises error if file is not JPEG' do
    path = file_fixture("fakeimage.jpeg")
    err = assert_raises Upload::UploadsError do
      Upload.create_avatar!(path)
    end
    assert_equal(I18n.t("incorrect_jpeg_format"), err.message)
  end

  test '.create_avatar! creates upload record' do
    path = file_fixture("realimage.jpeg")
    upload = Upload.create_avatar!(path)
    assert_equal(File.read(path.to_s), File.read(upload.path))
  ensure
    cleanup_avatars_dir
  end

  test '.create_avatar! returns existing uplpoad if it already exists' do
    path = file_fixture("realimage.jpeg")
    upload = Upload.create_avatar!(path)

    duplicate = Upload.create_avatar!(path)
    assert_equal(upload.id, duplicate.id)
  ensure
    cleanup_avatars_dir
  end

  test '.create_avatar! copies path to avatars dir unless the file already exists' do
    path = file_fixture("realimage.jpeg")
    upload = Upload.create_avatar!(path)
    assert(File.exists?(upload.path))
    File.delete(upload.path)
    assert_not(File.exists?(upload.path))

    duplicate = Upload.create_avatar!(path)
    assert_equal(upload.id, duplicate.id)
    assert(File.exists?(upload.path))
  ensure
    cleanup_avatars_dir
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
