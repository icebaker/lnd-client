# lnd-client

Ruby Lightning Network Daemon Client: Straightforward access to [lnd](https://github.com/lightningnetwork/lnd) [gRPC API](https://lightning.engineering/api-docs/api/lnd/#grpc)

This is a low-level client library. For a better experience, you may want to check out the [Lighstorm](https://github.com/icebaker/lighstorm) abstraction.

- [Usage](#usage)
  - [Documentation](https://icebaker.github.io/lnd-client)
- [Development](#development)
  - [Upgrading gRPC Proto Files](#upgrading-grpc-proto-files)
  - [Generating Documentation](#generating-documentation)
  - [Publish to RubyGems](#publish-to-rubygems)

## Usage

Add to your `Gemfile`:

```ruby
gem 'lnd-client', '~> 0.0.5'
```

```ruby
require 'lnd-client'

puts LNDClient.version # => 0.0.5

client = LNDClient.new(
  certificate_path: '/lnd/tls.cert',
  macaroon_path: '/lnd/data/chain/bitcoin/mainnet/admin.macaroon',
  socket_address: '127.0.0.1:10009'
)

client.lightning.wallet_balance.total_balance # => 101527

client.lightning.wallet_balance.to_h # =>
# {:total_balance=>101527,
#  :confirmed_balance=>101527,
#  :unconfirmed_balance=>0,
#  :locked_balance=>0,
#  :reserved_balance_anchor_chan=>20000,
#  :account_balance=>{"default"=>{:confirmed_balance=>101527, :unconfirmed_balance=>0}}}

client.lightning.get_node_info(
  pub_key: '02d3c80335a8ccb2ed364c06875f32240f36f7edb37d80f8dbe321b4c364b6e997'
).node.alias # => 'icebaker/old-stone'

client.lightning.subscribe_channel_graph do |data|
  puts data.inspect # => { ... }
end

client.router.subscribe_htlc_events do |data|
  puts data.inspect # => { ... }
end
```

Check the [full documentation](https://icebaker.github.io/lnd-client).

## Development

```ruby
# Gemfile
gem 'lnd-client', path: '/home/user/lnd-client'

# demo.rb
require 'lnd-client'

puts LNDClient.version
```

```sh
bundle
rubocop -A
```

### Upgrading gRPC Proto Files

```sh
bundle exec rake grpc:upgrade
```

### Generating Documentation

```sh
bundle exec rake grpc:docs

npm i docsify-cli -g

docsify serve ./docs
```

### Publish to RubyGems

```sh
gem build lnd-client.gemspec

gem signin

gem push lnd-client-0.0.5.gem
```
