# RoboMsg

RoboMsg is an HTTP client for FCM (Firebase Cloud Messaging). It implements [Firebase Cloud Messaging HTTP Protocol](https://firebase.google.com/docs/cloud-messaging/http-server-ref).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'robo_msg'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install robo_msg

## Usage

You'll need your application's server key, whose value is available in the [Cloud Messaging](https://console.firebase.google.com/project/_/settings/cloudmessaging) tab of the Firebase console Settings pane. Android, iOS, and browser keys are rejected by FCM.

```ruby
require 'robo_msg'

server_key   = "..." # Your server key
device_token = "..." # The device token of the device you'd like to push a message to

client   = RoboMsg.build(server_key)
response = client.push(to: device_token, notification: { title: "Update", body: "Your weekly summary is ready" }, data: { extra: "data" })

response = response.object
response.canonical_ids # => 0
response.failure       # => 0
response.multicast_id  # => 8478364278516813477

result = response.results
result.message_id      # => "0:1489498959348701%3b8aef473b8aef47"
result.error           # => nil, "InvalidRegistration" or something else
result.registration_id # => nil
```

## TODO

 * Remove the `object_mapper` gem from the dependency
 * Write integration tests
 * Add support for XMPP Protocol

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuki24/robo_msg. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
