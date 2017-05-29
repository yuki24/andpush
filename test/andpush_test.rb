require 'test_helper'

class AndpushTest < Minitest::Test
  def test_it_makes_http_request_to_fcm
    server_key   = ENV.fetch('FCM_TEST_SERVER_KEY')
    device_token = ENV.fetch('FCM_TEST_REGISTRATION_TOKEN')

    client = Andpush.build(server_key)
    json   = {
      to: device_token,
      dry_run: true,
      notification: {
        title: "Update",
        body: "Your weekly summary is ready"
      },
      data: {
        extra: "data"
      }
    }

    response = client.push(json)

    assert_equal '200', response.code
  end
end
