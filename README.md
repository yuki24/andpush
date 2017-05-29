# Andpush

Andpush is an HTTP client for FCM (Firebase Cloud Messaging). It implements [Firebase Cloud Messaging HTTP Protocol](https://firebase.google.com/docs/cloud-messaging/http-server-ref).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'andpush'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install andpush

## Usage

You'll need your application's server key, whose value is available in the [Cloud Messaging](https://console.firebase.google.com/project/_/settings/cloudmessaging) tab of the Firebase console Settings pane.

```ruby
require 'andpush'

server_key   = "..." # Your server key
device_token = "..." # The device token of the device you'd like to push a message to

client   = Andpush.build(server_key)
response = client.push(to: device_token, notification: { title: "Update", body: "Your weekly summary is ready" }, data: { extra: "data" })

json = response.json
json[:canonical_ids] # => 0
json[:failure]       # => 0
json[:multicast_id]  # => 8478364278516813477

result = json[:results].first
result[:message_id]      # => "0:1489498959348701%3b8aef473b8aef47"
result[:error]           # => nil, "InvalidRegistration" or something else
result[:registration_id] # => nil
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuki24/andpush. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
