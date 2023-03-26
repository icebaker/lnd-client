# lnd-client [![Gem Version](https://badge.fury.io/rb/lnd-client.svg)](https://badge.fury.io/rb/lnd-client) ![RSpec Tests Status](https://github.com/icebaker/lnd-client/actions/workflows/ruby-rspec-tests.yml/badge.svg)

Ruby Lightning Network Daemon Client: Straightforward access to [lnd](https://github.com/lightningnetwork/lnd) [gRPC API](https://lightning.engineering/api-docs/api/lnd/#grpc)

This is a low-level client library. For a better experience, you may want to check out the [Lighstorm](https://github.com/icebaker/lighstorm) abstraction.

- [Usage](#usage)
  - [Documentation](https://icebaker.github.io/lnd-client)
- [Available Supported Services][#available-supported-services]
- [Development](#development)
  - [Upgrading gRPC Proto Files](#upgrading-grpc-proto-files)
  - [Generating Documentation](#generating-documentation)
  - [Publish to RubyGems](#publish-to-rubygems)

## Usage

Add to your `Gemfile`:

```ruby
gem 'lnd-client', '~> 0.0.8'
```

```ruby
require 'lnd-client'

puts LNDClient.version # => 0.0.8

client = LNDClient.new(
  'lndconnect://127.0.0.1:10009?cert=MIICJz...JBEERQ&macaroon=AgEDbG...45ukJ4'
)

client.lightning.wallet_balance.total_balance # => 101527

client.lightning.wallet_balance.to_h # =>
# { total_balance: 101_527,
#   confirmed_balance: 101_527,
#   unconfirmed_balance: 0,
#   locked_balance: 0,
#   reserved_balance_anchor_chan: 20_000,
#   account_balance: {
#     'default' => {
#       confirmed_balance: 101_527,
#       unconfirmed_balance: 0 } } }

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

## Available Supported Services

- [autopilot](https://icebaker.github.io/lnd-client/#/README?id=autopilot)
- [chain_kit](https://icebaker.github.io/lnd-client/#/README?id=chain_kit)
- [chain_notifier](https://icebaker.github.io/lnd-client/#/README?id=chain_notifier)
- [dev](https://icebaker.github.io/lnd-client/#/README?id=dev)
- [invoices](https://icebaker.github.io/lnd-client/#/README?id=invoices)
- [lightning](https://icebaker.github.io/lnd-client/#/README?id=lightning)
- [neutrino_kit](https://icebaker.github.io/lnd-client/#/README?id=neutrino_kit)
- [peers](https://icebaker.github.io/lnd-client/#/README?id=peers)
- [router](https://icebaker.github.io/lnd-client/#/README?id=router)
- [signer](https://icebaker.github.io/lnd-client/#/README?id=signer)
- [state](https://icebaker.github.io/lnd-client/#/README?id=state)
- [versioner](https://icebaker.github.io/lnd-client/#/README?id=versioner)
- [wallet_kit](https://icebaker.github.io/lnd-client/#/README?id=wallet_kit)
- [wallet_unlocker](https://icebaker.github.io/lnd-client/#/README?id=wallet_unlocker)
- [watchtower](https://icebaker.github.io/lnd-client/#/README?id=watchtower)
- [watchtower_client](https://icebaker.github.io/lnd-client/#/README?id=watchtower_client)

## Development

Copy the `.env.example` file to `.env` and provide the required data.

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

gem push lnd-client-0.0.8.gem
```
