# Ruby _Lightning Network Daemon_ Client

> ⚠️ Warning: Early-stage, breaking changes are expected.

- [Usage](#usage)
  - [Channel Arguments](#channel-arguments)
  - [Documentation](#documentation)
- [Development](#development)
  - [Upgrading gRPC Proto Files](#upgrading-grpc-proto-files)
  - [Publish to RubyGems](#publish-to-rubygems)

## Usage

Add to your `Gemfile`:

```ruby
gem 'lnd-client', '~> 0.0.3'
```

```ruby
require 'lnd-client'

puts LNDClient.version # => 0.0.3

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

### Channel Arguments

```ruby
require 'lnd-client'

puts LNDClient.version # => 0.0.3

client = LNDClient.new(
  certificate_path: '/lnd/tls.cert',
  macaroon_path: '/lnd/data/chain/bitcoin/mainnet/admin.macaroon',
  socket_address: '127.0.0.1:10009'
)

client.lightning(
  channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 }
)

graph = client.lightning.describe_graph

graph.nodes # => [...]
graph.edges # => [...]
```

### Documentation

```ruby
require 'lnd-client'

puts LNDClient.version # => 0.0.3

client = LNDClient.new(
  certificate_path: '/lnd/tls.cert',
  macaroon_path: '/lnd/data/chain/bitcoin/mainnet/admin.macaroon',
  socket_address: '127.0.0.1:10009'
)

client.doc.services # => ['lightning', 'router']

client.lightning.doc.available_methods # =>
# ['abandon_channel',
#  'add_invoice',
#  'bake_macaroon',
#  'batch_open_channel',
#  'channel_acceptor',
#  'channel_balance',
#  'check_macaroon_permissions',
#  'close_channel',
#  'closed_channels',
#  # ...
#  'get_node_info'
# ]

client.lightning.doc.describe(:get_node_info) # =>
# { method: 'get_node_info',
#    input: { pub_key: '', include_channels: false},
#   output: { node: nil, num_channels: 0, total_capacity: 0, channels: []}}

client.lightning.doc.grpc(:get_node_info)
# #<struct GRPC::RpcDesc
#  name=:GetNodeInfo,
#  input=Lnrpc::NodeInfoRequest,
#  output=Lnrpc::NodeInfo,
#  marshal_method=:encode,
#  unmarshal_method=:decode>
```

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
### Publish to RubyGems

```sh
gem build lnd-client.gemspec

gem signin

gem push lnd-client-0.0.3.gem
```
