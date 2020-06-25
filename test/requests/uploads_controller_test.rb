# frozen_string_literal: true

require 'test_helper'

class UploadsControllerTest < CryptchatIntegrationTest
  test '#upload_avatar accepts JPEG files' do
    user = sign_in
    realimg = fixture_file_upload("files/realimage.jpeg")
    post '/avatar.json', params: { file: realimg }
    assert_equal(200, response.status)
    upload = Upload.find_by(id: response.parsed_body["avatar_id"])
    assert(File.exists?(upload.path))
    user.reload
    assert_equal(upload.id, user.avatar.id)
  ensure
    cleanup_avatars_dir
  end

  test '#upload_avatar requires current user' do
    realimg = fixture_file_upload("files/realimage.jpeg")
    post '/avatar.json', params: { file: realimg }
    assert_equal(403, response.status)
  ensure
    cleanup_avatars_dir
  end

  test '#upload_avatar rejects fake JPEG files' do
    user = sign_in
    fakeimg = fixture_file_upload("files/fakeimage.jpeg")
    post '/avatar.json', params: { file: fakeimg }
    assert_equal(422, response.status)
    assert_equal(I18n.t("incorrect_jpeg_format"), response.parsed_body["messages"].first)
    user.reload
    assert_nil(user.avatar_id)
  ensure
    cleanup_avatars_dir
  end

  test '#upload_avatar requires file' do
    user = sign_in
    post '/avatar.json'
    assert_equal(422, response.status)
    assert_equal(I18n.t("jpeg_file_required"), response.parsed_body["messages"].first)

    post '/avatar.json', params: { file: '/etc/passwd' }
    assert_equal(422, response.status)
    assert_equal(I18n.t("jpeg_file_required"), response.parsed_body["messages"].first)
  end

  test '#get_avatar renders avatar' do
    user = sign_in
    realimg = fixture_file_upload("files/realimage.jpeg")
    post '/avatar.json', params: { file: realimg }
    assert_equal(200, response.status)
    upload = Upload.find_by(id: response.parsed_body["avatar_id"])

    sign_in
    get "/avatar/#{upload.sha}"
    assert_equal(200, response.status)
    assert_equal('binary', response.headers["Content-Transfer-Encoding"])
    assert_includes(response.headers['Content-Disposition'], "#{upload.sha}.#{upload.extension}")
  ensure
    cleanup_avatars_dir
  end

  test '#get_avatar returns 404 for not found uploads' do
    sign_in
    get "/avatar/21321ab987cfe"
    assert_equal(404, response.status)
  end
end
