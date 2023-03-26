> Ruby Lightning Network Daemon (lnd) Client

Straightforward access to [lnd](https://github.com/lightningnetwork/lnd) [gRPC API](https://lightning.engineering/api-docs/api/lnd/#grpc)

This is a low-level client library. For a better experience, you may want to check out the [Lighstorm](https://github.com/icebaker/lighstorm) abstraction.

# Getting Started

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

## Runtime Documentation

```ruby
require 'lnd-client'

puts LNDClient.version # => 0.0.8

client = LNDClient.new(
  'lndconnect://127.0.0.1:10009?cert=MIICJz...JBEERQ&macaroon=AgEDbG...45ukJ4'
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

## Connecting

### lndconnect

Read more about [lnd connect URL](https://github.com/LN-Zap/lndconnect/blob/master/lnd_connect_uri.md).

```ruby
require 'lnd-client'

client = LNDClient.new(
  'lndconnect://127.0.0.1:10009?cert=MIICJz...JBEERQ&macaroon=AgEDbG...45ukJ4'
)
```

### File Path

```ruby
require 'lnd-client'

client = LNDClient.new(
  address: '127.0.0.1:10009',
  certificate_path: '/lnd/tls.cert',
  macaroon_path: '/lnd/data/chain/bitcoin/mainnet/admin.macaroon'
)
```

### Base64

```ruby
require 'lnd-client'

client = LNDClient.new(
  address: '127.0.0.1:10009',
  certificate: 'LS0tLS1CRU...UtLS0tLQo=',
  macaroon: 'AgEDbG5kAv...inv45ukJ4='
)
```

### Hex

```ruby
require 'lnd-client'

client = LNDClient.new(
  address: '127.0.0.1:10009',
  certificate: '2d2d2d2d2d...2d2d2d2d0a',
  macaroon: '0201036c6e...bf8e6e909e'
)
```

### Raw

```ruby
require 'lnd-client'

client = LNDClient.new(
  address: '127.0.0.1:10009',
  certificate: File.read('/lnd/tls.cert'),
  macaroon: File.read('/lnd/data/chain/bitcoin/mainnet/admin.macaroon')
)
```

## Channel Arguments

Read more about `GRPC::ResourceExhausted`: [Receive Large Responses](https://github.com/lightningnetwork/lnd/blob/master/docs/grpc/ruby.md#receive-large-responses)

```ruby
require 'lnd-client'

# lndconnect
client = LNDClient.new(
  'lndconnect://127.0.0.1:10009?cert=MIICJz...JBEERQ&macaroon=AgEDbG...45ukJ4',
  lightning: {
    channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 }
  }
)

# Base64
client = LNDClient.new(
  address: '127.0.0.1:10009',
  certificate: 'LS0tLS1CRU...UtLS0tLQo=',
  macaroon: 'AgEDbG5kAv...inv45ukJ4=',
  lightning: {
    channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 }
  }
)

graph = client.lightning.describe_graph

graph.nodes # => [...]
graph.edges # => [...]
```

## Multiclient

Multiclient allows you to establish connections with multiple nodes and effortlessly switch between them without needing to create and manage individual client instances.

```ruby
LNDClient.add_connection!(
  'alice',
  'lndconnect://127.0.0.1:10009?cert=MIICJz...JBEERQ&macaroon=AgEDbG...45ukJ4'
)

LNDClient.add_connection!(
  'bob',
  address: '127.0.0.1:10009',
  certificate: 'LS0tLS1CRU...UtLS0tLQo=',
  macaroon: 'AgEDbG5kAv...inv45ukJ4=',
  lightning: {
    channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 }
  }
)

LNDClient.as('alice').lightning.wallet_balance.total_balance
LNDClient.as('bob').lightning.wallet_balance.total_balance

LNDClient.connections # => ['alice', 'bob']

LNDClient.remove_connection!('bob')

LNDClient.connections # => ['alice']
```

## Docker and Remote Access

To connect to an LND node through a Docker container or remote host, you may need to adjust your certificate settings. Follow these steps:

1. Stop your LND node.

2. Remove or backup existing certificate files (`tls.cert` and `tls.key`) in the LND directory.

3. Modify `lnd.conf` to include the relevant `tlsextraip` and/or `tlsextradomain` settings:

Option A: Accept any IP or domain (Warning: high security risk):

```conf
tlsextraip=0.0.0.0
```

Option B: Accept only your Docker host (172.17.0.1):
```conf
tlsextraip=172.17.0.1
```

Option C: Accept a specific remote domain and host:
```config
tlsextraip=<your_remote_host_ip>
tlsextradomain=<your_domain_name>
```

4. Save and restart your LND node. New tls.cert and tls.key files will be generated.

5. Update your LND client configuration with the new certificate.

Choose the option that best suits your needs and environment while considering security implications.

# Development

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

## Upgrading gRPC Proto Files

```sh
bundle exec rake grpc:upgrade
```

## Generating Documentation

```sh
bundle exec rake grpc:docs

npm i docsify-cli -g

docsify serve ./docs
```

## Publish to RubyGems

```sh
gem build lnd-client.gemspec

gem signin

gem push lnd-client-0.0.8.gem
```

# Services

<!-- [INJECT:GRP:DOCS] -->

## lightning

### abandon_channel

[lightning.engineering/lightning/abandon-channel](https://lightning.engineering/api-docs/api/lnd/lightning/abandon-channel/index.html)

```ruby
client.lightning.abandon_channel(
  { channel_point: nil,
    pending_funding_shim_only: false,
    i_know_what_i_am_doing: false }
)
```

### add_invoice

[lightning.engineering/lightning/add-invoice](https://lightning.engineering/api-docs/api/lnd/lightning/add-invoice/index.html)

```ruby
client.lightning.add_invoice(
  { memo: '',
    r_preimage: '',
    r_hash: '',
    value: 0,
    value_msat: 0,
    settled: false,
    creation_date: 0,
    settle_date: 0,
    payment_request: '',
    description_hash: '',
    expiry: 0,
    fallback_addr: '',
    cltv_expiry: 0,
    route_hints: [],
    private: false,
    add_index: 0,
    settle_index: 0,
    amt_paid: 0,
    amt_paid_sat: 0,
    amt_paid_msat: 0,
    state: :OPEN,
    htlcs: [],
    features: {},
    is_keysend: false,
    payment_addr: '',
    is_amp: false,
    amp_invoice_state: {} }
)
```

Output:
```ruby
{ r_hash: '',
  payment_request: '',
  add_index: 0,
  payment_addr: '' }
```

### bake_macaroon

[lightning.engineering/lightning/bake-macaroon](https://lightning.engineering/api-docs/api/lnd/lightning/bake-macaroon/index.html)

```ruby
client.lightning.bake_macaroon(
  { permissions: [],
    root_key_id: 0,
    allow_external_permissions: false }
)
```

Output:
```ruby
{ macaroon: '' }
```

### batch_open_channel

[lightning.engineering/lightning/batch-open-channel](https://lightning.engineering/api-docs/api/lnd/lightning/batch-open-channel/index.html)

```ruby
client.lightning.batch_open_channel(
  { channels: [],
    target_conf: 0,
    sat_per_vbyte: 0,
    min_confs: 0,
    spend_unconfirmed: false,
    label: '' }
)
```

Output:
```ruby
{ pending_channels: [] }
```

### channel_acceptor

[lightning.engineering/lightning/channel-acceptor](https://lightning.engineering/api-docs/api/lnd/lightning/channel-acceptor/index.html)

```ruby
client.lightning.channel_acceptor
```

### channel_balance

[lightning.engineering/lightning/channel-balance](https://lightning.engineering/api-docs/api/lnd/lightning/channel-balance/index.html)

```ruby
client.lightning.channel_balance
```

Output:
```ruby
{ balance: 0,
  pending_open_balance: 0,
  local_balance: nil,
  remote_balance: nil,
  unsettled_local_balance: nil,
  unsettled_remote_balance: nil,
  pending_open_local_balance: nil,
  pending_open_remote_balance: nil }
```

### check_macaroon_permissions

[lightning.engineering/lightning/check-macaroon-permissions](https://lightning.engineering/api-docs/api/lnd/lightning/check-macaroon-permissions/index.html)

```ruby
client.lightning.check_macaroon_permissions(
  { macaroon: '',
    permissions: [],
    fullMethod: '' }
)
```

Output:
```ruby
{ valid: false }
```

### close_channel

[lightning.engineering/lightning/close-channel](https://lightning.engineering/api-docs/api/lnd/lightning/close-channel/index.html)

```ruby
client.lightning.close_channel(
  { channel_point: nil,
    force: false,
    target_conf: 0,
    sat_per_byte: 0,
    delivery_address: '',
    sat_per_vbyte: 0,
    max_fee_per_vbyte: 0 }
)
```

### closed_channels

[lightning.engineering/lightning/closed-channels](https://lightning.engineering/api-docs/api/lnd/lightning/closed-channels/index.html)

```ruby
client.lightning.closed_channels(
  { cooperative: false,
    local_force: false,
    remote_force: false,
    breach: false,
    funding_canceled: false,
    abandoned: false }
)
```

Output:
```ruby
{ channels: [] }
```

### connect_peer

[lightning.engineering/lightning/connect-peer](https://lightning.engineering/api-docs/api/lnd/lightning/connect-peer/index.html)

```ruby
client.lightning.connect_peer(
  { addr: nil,
    perm: false,
    timeout: 0 }
)
```

### debug_level

[lightning.engineering/lightning/debug-level](https://lightning.engineering/api-docs/api/lnd/lightning/debug-level/index.html)

```ruby
client.lightning.debug_level(
  { show: false,
    level_spec: '' }
)
```

Output:
```ruby
{ sub_systems: '' }
```

### decode_pay_req

[lightning.engineering/lightning/decode-pay-req](https://lightning.engineering/api-docs/api/lnd/lightning/decode-pay-req/index.html)

```ruby
client.lightning.decode_pay_req(
  { pay_req: '' }
)
```

Output:
```ruby
{ destination: '',
  payment_hash: '',
  num_satoshis: 0,
  timestamp: 0,
  expiry: 0,
  description: '',
  description_hash: '',
  fallback_addr: '',
  cltv_expiry: 0,
  route_hints: [],
  payment_addr: '',
  num_msat: 0,
  features: {} }
```

### delete_all_payments

[lightning.engineering/lightning/delete-all-payments](https://lightning.engineering/api-docs/api/lnd/lightning/delete-all-payments/index.html)

```ruby
client.lightning.delete_all_payments(
  { failed_payments_only: false,
    failed_htlcs_only: false }
)
```

### delete_macaroon_id

[lightning.engineering/lightning/delete-macaroon-id](https://lightning.engineering/api-docs/api/lnd/lightning/delete-macaroon-id/index.html)

```ruby
client.lightning.delete_macaroon_id(
  { root_key_id: 0 }
)
```

Output:
```ruby
{ deleted: false }
```

### delete_payment

[lightning.engineering/lightning/delete-payment](https://lightning.engineering/api-docs/api/lnd/lightning/delete-payment/index.html)

```ruby
client.lightning.delete_payment(
  { payment_hash: '',
    failed_htlcs_only: false }
)
```

### describe_graph

[lightning.engineering/lightning/describe-graph](https://lightning.engineering/api-docs/api/lnd/lightning/describe-graph/index.html)

```ruby
client.lightning.describe_graph(
  { include_unannounced: false }
)
```

Output:
```ruby
{ nodes: [],
  edges: [] }
```

### disconnect_peer

[lightning.engineering/lightning/disconnect-peer](https://lightning.engineering/api-docs/api/lnd/lightning/disconnect-peer/index.html)

```ruby
client.lightning.disconnect_peer(
  { pub_key: '' }
)
```

### estimate_fee

[lightning.engineering/lightning/estimate-fee](https://lightning.engineering/api-docs/api/lnd/lightning/estimate-fee/index.html)

```ruby
client.lightning.estimate_fee(
  { AddrToAmount: {},
    target_conf: 0,
    min_confs: 0,
    spend_unconfirmed: false }
)
```

Output:
```ruby
{ fee_sat: 0,
  feerate_sat_per_byte: 0,
  sat_per_vbyte: 0 }
```

### export_all_channel_backups

[lightning.engineering/lightning/export-all-channel-backups](https://lightning.engineering/api-docs/api/lnd/lightning/export-all-channel-backups/index.html)

```ruby
client.lightning.export_all_channel_backups
```

Output:
```ruby
{ single_chan_backups: nil,
  multi_chan_backup: nil }
```

### export_channel_backup

[lightning.engineering/lightning/export-channel-backup](https://lightning.engineering/api-docs/api/lnd/lightning/export-channel-backup/index.html)

```ruby
client.lightning.export_channel_backup(
  { chan_point: nil }
)
```

Output:
```ruby
{ chan_point: nil,
  chan_backup: '' }
```

### fee_report

[lightning.engineering/lightning/fee-report](https://lightning.engineering/api-docs/api/lnd/lightning/fee-report/index.html)

```ruby
client.lightning.fee_report
```

Output:
```ruby
{ channel_fees: [],
  day_fee_sum: 0,
  week_fee_sum: 0,
  month_fee_sum: 0 }
```

### forwarding_history

[lightning.engineering/lightning/forwarding-history](https://lightning.engineering/api-docs/api/lnd/lightning/forwarding-history/index.html)

```ruby
client.lightning.forwarding_history(
  { start_time: 0,
    end_time: 0,
    index_offset: 0,
    num_max_events: 0,
    peer_alias_lookup: false }
)
```

Output:
```ruby
{ forwarding_events: [],
  last_offset_index: 0 }
```

### funding_state_step

[lightning.engineering/lightning/funding-state-step](https://lightning.engineering/api-docs/api/lnd/lightning/funding-state-step/index.html)

```ruby
client.lightning.funding_state_step(
  { shim_register: nil,
    shim_cancel: nil,
    psbt_verify: nil,
    psbt_finalize: nil }
)
```

### get_chan_info

[lightning.engineering/lightning/get-chan-info](https://lightning.engineering/api-docs/api/lnd/lightning/get-chan-info/index.html)

```ruby
client.lightning.get_chan_info(
  { chan_id: 0 }
)
```

Output:
```ruby
{ channel_id: 0,
  chan_point: '',
  last_update: 0,
  node1_pub: '',
  node2_pub: '',
  capacity: 0,
  node1_policy: nil,
  node2_policy: nil,
  custom_records: {} }
```

### get_info

[lightning.engineering/lightning/get-info](https://lightning.engineering/api-docs/api/lnd/lightning/get-info/index.html)

```ruby
client.lightning.get_info
```

Output:
```ruby
{ version: '',
  commit_hash: '',
  identity_pubkey: '',
  alias: '',
  color: '',
  num_pending_channels: 0,
  num_active_channels: 0,
  num_inactive_channels: 0,
  num_peers: 0,
  block_height: 0,
  block_hash: '',
  best_header_timestamp: 0,
  synced_to_chain: false,
  synced_to_graph: false,
  testnet: false,
  chains: [],
  uris: [],
  features: {},
  require_htlc_interceptor: false }
```

### get_network_info

[lightning.engineering/lightning/get-network-info](https://lightning.engineering/api-docs/api/lnd/lightning/get-network-info/index.html)

```ruby
client.lightning.get_network_info
```

Output:
```ruby
{ graph_diameter: 0,
  avg_out_degree: 0.0,
  max_out_degree: 0,
  num_nodes: 0,
  num_channels: 0,
  total_network_capacity: 0,
  avg_channel_size: 0.0,
  min_channel_size: 0,
  max_channel_size: 0,
  median_channel_size_sat: 0,
  num_zombie_chans: 0 }
```

### get_node_info

[lightning.engineering/lightning/get-node-info](https://lightning.engineering/api-docs/api/lnd/lightning/get-node-info/index.html)

```ruby
client.lightning.get_node_info(
  { pub_key: '',
    include_channels: false }
)
```

Output:
```ruby
{ node: nil,
  num_channels: 0,
  total_capacity: 0,
  channels: [] }
```

### get_node_metrics

[lightning.engineering/lightning/get-node-metrics](https://lightning.engineering/api-docs/api/lnd/lightning/get-node-metrics/index.html)

```ruby
client.lightning.get_node_metrics(
  { types: [] }
)
```

Output:
```ruby
{ betweenness_centrality: {} }
```

### get_recovery_info

[lightning.engineering/lightning/get-recovery-info](https://lightning.engineering/api-docs/api/lnd/lightning/get-recovery-info/index.html)

```ruby
client.lightning.get_recovery_info
```

Output:
```ruby
{ recovery_mode: false,
  recovery_finished: false,
  progress: 0.0 }
```

### get_transactions

[lightning.engineering/lightning/get-transactions](https://lightning.engineering/api-docs/api/lnd/lightning/get-transactions/index.html)

```ruby
client.lightning.get_transactions(
  { start_height: 0,
    end_height: 0,
    account: '' }
)
```

Output:
```ruby
{ transactions: [] }
```

### list_aliases

[lightning.engineering/lightning/list-aliases](https://lightning.engineering/api-docs/api/lnd/lightning/list-aliases/index.html)

```ruby
client.lightning.list_aliases
```

Output:
```ruby
{ alias_maps: [] }
```

### list_channels

[lightning.engineering/lightning/list-channels](https://lightning.engineering/api-docs/api/lnd/lightning/list-channels/index.html)

```ruby
client.lightning.list_channels(
  { active_only: false,
    inactive_only: false,
    public_only: false,
    private_only: false,
    peer: '' }
)
```

Output:
```ruby
{ channels: [] }
```

### list_invoices

[lightning.engineering/lightning/list-invoices](https://lightning.engineering/api-docs/api/lnd/lightning/list-invoices/index.html)

```ruby
client.lightning.list_invoices(
  { pending_only: false,
    index_offset: 0,
    num_max_invoices: 0,
    reversed: false,
    creation_date_start: 0,
    creation_date_end: 0 }
)
```

Output:
```ruby
{ invoices: [],
  last_index_offset: 0,
  first_index_offset: 0 }
```

### list_macaroon_i_ds

[lightning.engineering/lightning/list-macaroon-i-ds](https://lightning.engineering/api-docs/api/lnd/lightning/list-macaroon-i-ds/index.html)

```ruby
client.lightning.list_macaroon_i_ds
```

Output:
```ruby
{ root_key_ids: [] }
```

### list_payments

[lightning.engineering/lightning/list-payments](https://lightning.engineering/api-docs/api/lnd/lightning/list-payments/index.html)

```ruby
client.lightning.list_payments(
  { include_incomplete: false,
    index_offset: 0,
    max_payments: 0,
    reversed: false,
    count_total_payments: false,
    creation_date_start: 0,
    creation_date_end: 0 }
)
```

Output:
```ruby
{ payments: [],
  first_index_offset: 0,
  last_index_offset: 0,
  total_num_payments: 0 }
```

### list_peers

[lightning.engineering/lightning/list-peers](https://lightning.engineering/api-docs/api/lnd/lightning/list-peers/index.html)

```ruby
client.lightning.list_peers(
  { latest_error: false }
)
```

Output:
```ruby
{ peers: [] }
```

### list_permissions

[lightning.engineering/lightning/list-permissions](https://lightning.engineering/api-docs/api/lnd/lightning/list-permissions/index.html)

```ruby
client.lightning.list_permissions
```

Output:
```ruby
{ method_permissions: {} }
```

### list_unspent

[lightning.engineering/lightning/list-unspent](https://lightning.engineering/api-docs/api/lnd/lightning/list-unspent/index.html)

```ruby
client.lightning.list_unspent(
  { min_confs: 0,
    max_confs: 0,
    account: '' }
)
```

Output:
```ruby
{ utxos: [] }
```

### lookup_htlc

[lightning.engineering/lightning/lookup-htlc](https://lightning.engineering/api-docs/api/lnd/lightning/lookup-htlc/index.html)

```ruby
client.lightning.lookup_htlc(
  { chan_id: 0,
    htlc_index: 0 }
)
```

Output:
```ruby
{ settled: false,
  offchain: false }
```

### lookup_invoice

[lightning.engineering/lightning/lookup-invoice](https://lightning.engineering/api-docs/api/lnd/lightning/lookup-invoice/index.html)

```ruby
client.lightning.lookup_invoice(
  { r_hash_str: '',
    r_hash: '' }
)
```

Output:
```ruby
{ memo: '',
  r_preimage: '',
  r_hash: '',
  value: 0,
  value_msat: 0,
  settled: false,
  creation_date: 0,
  settle_date: 0,
  payment_request: '',
  description_hash: '',
  expiry: 0,
  fallback_addr: '',
  cltv_expiry: 0,
  route_hints: [],
  private: false,
  add_index: 0,
  settle_index: 0,
  amt_paid: 0,
  amt_paid_sat: 0,
  amt_paid_msat: 0,
  state: :OPEN,
  htlcs: [],
  features: {},
  is_keysend: false,
  payment_addr: '',
  is_amp: false,
  amp_invoice_state: {} }
```

### new_address

[lightning.engineering/lightning/new-address](https://lightning.engineering/api-docs/api/lnd/lightning/new-address/index.html)

```ruby
client.lightning.new_address(
  { type: :WITNESS_PUBKEY_HASH,
    account: '' }
)
```

Output:
```ruby
{ address: '' }
```

### open_channel

[lightning.engineering/lightning/open-channel](https://lightning.engineering/api-docs/api/lnd/lightning/open-channel/index.html)

```ruby
client.lightning.open_channel(
  { sat_per_vbyte: 0,
    node_pubkey: '',
    node_pubkey_string: '',
    local_funding_amount: 0,
    push_sat: 0,
    target_conf: 0,
    sat_per_byte: 0,
    private: false,
    min_htlc_msat: 0,
    remote_csv_delay: 0,
    min_confs: 0,
    spend_unconfirmed: false,
    close_address: '',
    funding_shim: nil,
    remote_max_value_in_flight_msat: 0,
    remote_max_htlcs: 0,
    max_local_csv: 0,
    commitment_type: :UNKNOWN_COMMITMENT_TYPE,
    zero_conf: false,
    scid_alias: false,
    base_fee: 0,
    fee_rate: 0,
    use_base_fee: false,
    use_fee_rate: false,
    remote_chan_reserve_sat: 0 }
)
```

### open_channel_sync

[lightning.engineering/lightning/open-channel-sync](https://lightning.engineering/api-docs/api/lnd/lightning/open-channel-sync/index.html)

```ruby
client.lightning.open_channel_sync(
  { sat_per_vbyte: 0,
    node_pubkey: '',
    node_pubkey_string: '',
    local_funding_amount: 0,
    push_sat: 0,
    target_conf: 0,
    sat_per_byte: 0,
    private: false,
    min_htlc_msat: 0,
    remote_csv_delay: 0,
    min_confs: 0,
    spend_unconfirmed: false,
    close_address: '',
    funding_shim: nil,
    remote_max_value_in_flight_msat: 0,
    remote_max_htlcs: 0,
    max_local_csv: 0,
    commitment_type: :UNKNOWN_COMMITMENT_TYPE,
    zero_conf: false,
    scid_alias: false,
    base_fee: 0,
    fee_rate: 0,
    use_base_fee: false,
    use_fee_rate: false,
    remote_chan_reserve_sat: 0 }
)
```

Output:
```ruby
{ output_index: 0,
  funding_txid_bytes: '',
  funding_txid_str: '' }
```

### pending_channels

[lightning.engineering/lightning/pending-channels](https://lightning.engineering/api-docs/api/lnd/lightning/pending-channels/index.html)

```ruby
client.lightning.pending_channels
```

Output:
```ruby
{ total_limbo_balance: 0,
  pending_open_channels: [],
  pending_closing_channels: [],
  pending_force_closing_channels: [],
  waiting_close_channels: [] }
```

### query_routes

[lightning.engineering/lightning/query-routes](https://lightning.engineering/api-docs/api/lnd/lightning/query-routes/index.html)

```ruby
client.lightning.query_routes(
  { pub_key: '',
    amt: 0,
    amt_msat: 0,
    final_cltv_delta: 0,
    fee_limit: nil,
    ignored_nodes: [],
    ignored_edges: [],
    source_pub_key: '',
    use_mission_control: false,
    ignored_pairs: [],
    cltv_limit: 0,
    dest_custom_records: {},
    outgoing_chan_id: 0,
    last_hop_pubkey: '',
    route_hints: [],
    dest_features: [],
    time_pref: 0.0 }
)
```

Output:
```ruby
{ routes: [],
  success_prob: 0.0 }
```

### register_rpc_middleware

[lightning.engineering/lightning/register-rpc-middleware](https://lightning.engineering/api-docs/api/lnd/lightning/register-rpc-middleware/index.html)

```ruby
client.lightning.register_rpc_middleware
```

### restore_channel_backups

[lightning.engineering/lightning/restore-channel-backups](https://lightning.engineering/api-docs/api/lnd/lightning/restore-channel-backups/index.html)

```ruby
client.lightning.restore_channel_backups(
  { chan_backups: nil,
    multi_chan_backup: '' }
)
```

### send_coins

[lightning.engineering/lightning/send-coins](https://lightning.engineering/api-docs/api/lnd/lightning/send-coins/index.html)

```ruby
client.lightning.send_coins(
  { addr: '',
    amount: 0,
    target_conf: 0,
    sat_per_vbyte: 0,
    sat_per_byte: 0,
    send_all: false,
    label: '',
    min_confs: 0,
    spend_unconfirmed: false }
)
```

Output:
```ruby
{ txid: '' }
```

### send_custom_message

[lightning.engineering/lightning/send-custom-message](https://lightning.engineering/api-docs/api/lnd/lightning/send-custom-message/index.html)

```ruby
client.lightning.send_custom_message(
  { peer: '',
    type: 0,
    data: '' }
)
```

### send_many

[lightning.engineering/lightning/send-many](https://lightning.engineering/api-docs/api/lnd/lightning/send-many/index.html)

```ruby
client.lightning.send_many(
  { AddrToAmount: {},
    target_conf: 0,
    sat_per_vbyte: 0,
    sat_per_byte: 0,
    label: '',
    min_confs: 0,
    spend_unconfirmed: false }
)
```

Output:
```ruby
{ txid: '' }
```

### send_payment

[lightning.engineering/lightning/send-payment](https://lightning.engineering/api-docs/api/lnd/lightning/send-payment/index.html)

```ruby
client.lightning.send_payment
```

### send_payment_sync

[lightning.engineering/lightning/send-payment-sync](https://lightning.engineering/api-docs/api/lnd/lightning/send-payment-sync/index.html)

```ruby
client.lightning.send_payment_sync(
  { dest: '',
    dest_string: '',
    amt: 0,
    amt_msat: 0,
    payment_hash: '',
    payment_hash_string: '',
    payment_request: '',
    final_cltv_delta: 0,
    fee_limit: nil,
    outgoing_chan_id: 0,
    last_hop_pubkey: '',
    cltv_limit: 0,
    dest_custom_records: {},
    allow_self_payment: false,
    dest_features: [],
    payment_addr: '' }
)
```

Output:
```ruby
{ payment_error: '',
  payment_preimage: '',
  payment_route: nil,
  payment_hash: '' }
```

### send_to_route

[lightning.engineering/lightning/send-to-route](https://lightning.engineering/api-docs/api/lnd/lightning/send-to-route/index.html)

```ruby
client.lightning.send_to_route
```

### send_to_route_sync

[lightning.engineering/lightning/send-to-route-sync](https://lightning.engineering/api-docs/api/lnd/lightning/send-to-route-sync/index.html)

```ruby
client.lightning.send_to_route_sync(
  { payment_hash: '',
    payment_hash_string: '',
    route: nil }
)
```

Output:
```ruby
{ payment_error: '',
  payment_preimage: '',
  payment_route: nil,
  payment_hash: '' }
```

### sign_message

[lightning.engineering/lightning/sign-message](https://lightning.engineering/api-docs/api/lnd/lightning/sign-message/index.html)

```ruby
client.lightning.sign_message(
  { msg: '',
    single_hash: false }
)
```

Output:
```ruby
{ signature: '' }
```

### stop_daemon

[lightning.engineering/lightning/stop-daemon](https://lightning.engineering/api-docs/api/lnd/lightning/stop-daemon/index.html)

```ruby
client.lightning.stop_daemon
```

### subscribe_channel_backups

[lightning.engineering/lightning/subscribe-channel-backups](https://lightning.engineering/api-docs/api/lnd/lightning/subscribe-channel-backups/index.html)

```ruby
client.lightning.subscribe_channel_backups do |data|
  puts data.inspect # => { ... }
end
```

### subscribe_channel_events

[lightning.engineering/lightning/subscribe-channel-events](https://lightning.engineering/api-docs/api/lnd/lightning/subscribe-channel-events/index.html)

```ruby
client.lightning.subscribe_channel_events do |data|
  puts data.inspect # => { ... }
end
```

### subscribe_channel_graph

[lightning.engineering/lightning/subscribe-channel-graph](https://lightning.engineering/api-docs/api/lnd/lightning/subscribe-channel-graph/index.html)

```ruby
client.lightning.subscribe_channel_graph do |data|
  puts data.inspect # => { ... }
end
```

### subscribe_custom_messages

[lightning.engineering/lightning/subscribe-custom-messages](https://lightning.engineering/api-docs/api/lnd/lightning/subscribe-custom-messages/index.html)

```ruby
client.lightning.subscribe_custom_messages do |data|
  puts data.inspect # => { ... }
end
```

### subscribe_invoices

[lightning.engineering/lightning/subscribe-invoices](https://lightning.engineering/api-docs/api/lnd/lightning/subscribe-invoices/index.html)

```ruby
client.lightning.subscribe_invoices(
  { add_index: 0,
    settle_index: 0 }
) do |data|
  puts data.inspect # => { ... }
end
```

### subscribe_peer_events

[lightning.engineering/lightning/subscribe-peer-events](https://lightning.engineering/api-docs/api/lnd/lightning/subscribe-peer-events/index.html)

```ruby
client.lightning.subscribe_peer_events do |data|
  puts data.inspect # => { ... }
end
```

### subscribe_transactions

[lightning.engineering/lightning/subscribe-transactions](https://lightning.engineering/api-docs/api/lnd/lightning/subscribe-transactions/index.html)

```ruby
client.lightning.subscribe_transactions(
  { start_height: 0,
    end_height: 0,
    account: '' }
) do |data|
  puts data.inspect # => { ... }
end
```

### update_channel_policy

[lightning.engineering/lightning/update-channel-policy](https://lightning.engineering/api-docs/api/lnd/lightning/update-channel-policy/index.html)

```ruby
client.lightning.update_channel_policy(
  { base_fee_msat: 0,
    fee_rate: 0.0,
    fee_rate_ppm: 0,
    time_lock_delta: 0,
    max_htlc_msat: 0,
    min_htlc_msat: 0,
    min_htlc_msat_specified: false,
    global: false,
    chan_point: nil }
)
```

Output:
```ruby
{ failed_updates: [] }
```

### verify_chan_backup

[lightning.engineering/lightning/verify-chan-backup](https://lightning.engineering/api-docs/api/lnd/lightning/verify-chan-backup/index.html)

```ruby
client.lightning.verify_chan_backup(
  { single_chan_backups: nil,
    multi_chan_backup: nil }
)
```

### verify_message

[lightning.engineering/lightning/verify-message](https://lightning.engineering/api-docs/api/lnd/lightning/verify-message/index.html)

```ruby
client.lightning.verify_message(
  { msg: '',
    signature: '' }
)
```

Output:
```ruby
{ valid: false,
  pubkey: '' }
```

### wallet_balance

[lightning.engineering/lightning/wallet-balance](https://lightning.engineering/api-docs/api/lnd/lightning/wallet-balance/index.html)

```ruby
client.lightning.wallet_balance
```

Output:
```ruby
{ total_balance: 0,
  confirmed_balance: 0,
  unconfirmed_balance: 0,
  locked_balance: 0,
  reserved_balance_anchor_chan: 0,
  account_balance: {} }
```
## router

### build_route

[lightning.engineering/router/build-route](https://lightning.engineering/api-docs/api/lnd/router/build-route/index.html)

```ruby
client.router.build_route(
  { amt_msat: 0,
    final_cltv_delta: 0,
    outgoing_chan_id: 0,
    hop_pubkeys: [],
    payment_addr: '' }
)
```

Output:
```ruby
{ route: nil }
```

### estimate_route_fee

[lightning.engineering/router/estimate-route-fee](https://lightning.engineering/api-docs/api/lnd/router/estimate-route-fee/index.html)

```ruby
client.router.estimate_route_fee(
  { dest: '',
    amt_sat: 0 }
)
```

Output:
```ruby
{ routing_fee_msat: 0,
  time_lock_delay: 0 }
```

### get_mission_control_config

[lightning.engineering/router/get-mission-control-config](https://lightning.engineering/api-docs/api/lnd/router/get-mission-control-config/index.html)

```ruby
client.router.get_mission_control_config
```

Output:
```ruby
{ config: nil }
```

### htlc_interceptor

[lightning.engineering/router/htlc-interceptor](https://lightning.engineering/api-docs/api/lnd/router/htlc-interceptor/index.html)

```ruby
client.router.htlc_interceptor
```

### query_mission_control

[lightning.engineering/router/query-mission-control](https://lightning.engineering/api-docs/api/lnd/router/query-mission-control/index.html)

```ruby
client.router.query_mission_control
```

Output:
```ruby
{ pairs: [] }
```

### query_probability

[lightning.engineering/router/query-probability](https://lightning.engineering/api-docs/api/lnd/router/query-probability/index.html)

```ruby
client.router.query_probability(
  { from_node: '',
    to_node: '',
    amt_msat: 0 }
)
```

Output:
```ruby
{ probability: 0.0,
  history: nil }
```

### reset_mission_control

[lightning.engineering/router/reset-mission-control](https://lightning.engineering/api-docs/api/lnd/router/reset-mission-control/index.html)

```ruby
client.router.reset_mission_control
```

### send_payment

[lightning.engineering/router/send-payment](https://lightning.engineering/api-docs/api/lnd/router/send-payment/index.html)

```ruby
client.router.send_payment(
  { dest: '',
    amt: 0,
    amt_msat: 0,
    payment_hash: '',
    final_cltv_delta: 0,
    payment_addr: '',
    payment_request: '',
    timeout_seconds: 0,
    fee_limit_sat: 0,
    fee_limit_msat: 0,
    outgoing_chan_id: 0,
    outgoing_chan_ids: [],
    last_hop_pubkey: '',
    cltv_limit: 0,
    route_hints: [],
    dest_custom_records: {},
    allow_self_payment: false,
    dest_features: [],
    max_parts: 0,
    no_inflight_updates: false,
    max_shard_size_msat: 0,
    amp: false,
    time_pref: 0.0 }
)
```

### send_payment_v2

[lightning.engineering/router/send-payment-v2](https://lightning.engineering/api-docs/api/lnd/router/send-payment-v2/index.html)

```ruby
client.router.send_payment_v2(
  { dest: '',
    amt: 0,
    amt_msat: 0,
    payment_hash: '',
    final_cltv_delta: 0,
    payment_addr: '',
    payment_request: '',
    timeout_seconds: 0,
    fee_limit_sat: 0,
    fee_limit_msat: 0,
    outgoing_chan_id: 0,
    outgoing_chan_ids: [],
    last_hop_pubkey: '',
    cltv_limit: 0,
    route_hints: [],
    dest_custom_records: {},
    allow_self_payment: false,
    dest_features: [],
    max_parts: 0,
    no_inflight_updates: false,
    max_shard_size_msat: 0,
    amp: false,
    time_pref: 0.0 }
)
```

### send_to_route

[lightning.engineering/router/send-to-route](https://lightning.engineering/api-docs/api/lnd/router/send-to-route/index.html)

```ruby
client.router.send_to_route(
  { payment_hash: '',
    route: nil,
    skip_temp_err: false }
)
```

Output:
```ruby
{ preimage: '',
  failure: nil }
```

### send_to_route_v2

[lightning.engineering/router/send-to-route-v2](https://lightning.engineering/api-docs/api/lnd/router/send-to-route-v2/index.html)

```ruby
client.router.send_to_route_v2(
  { payment_hash: '',
    route: nil,
    skip_temp_err: false }
)
```

Output:
```ruby
{ attempt_id: 0,
  status: :IN_FLIGHT,
  route: nil,
  attempt_time_ns: 0,
  resolve_time_ns: 0,
  failure: nil,
  preimage: '' }
```

### set_mission_control_config

[lightning.engineering/router/set-mission-control-config](https://lightning.engineering/api-docs/api/lnd/router/set-mission-control-config/index.html)

```ruby
client.router.set_mission_control_config(
  { config: nil }
)
```

### subscribe_htlc_events

[lightning.engineering/router/subscribe-htlc-events](https://lightning.engineering/api-docs/api/lnd/router/subscribe-htlc-events/index.html)

```ruby
client.router.subscribe_htlc_events do |data|
  puts data.inspect # => { ... }
end
```

### track_payment

[lightning.engineering/router/track-payment](https://lightning.engineering/api-docs/api/lnd/router/track-payment/index.html)

```ruby
client.router.track_payment(
  { payment_hash: '',
    no_inflight_updates: false }
)
```

### track_payment_v2

[lightning.engineering/router/track-payment-v2](https://lightning.engineering/api-docs/api/lnd/router/track-payment-v2/index.html)

```ruby
client.router.track_payment_v2(
  { payment_hash: '',
    no_inflight_updates: false }
)
```

### track_payments

[lightning.engineering/router/track-payments](https://lightning.engineering/api-docs/api/lnd/router/track-payments/index.html)

```ruby
client.router.track_payments(
  { no_inflight_updates: false }
)
```

### update_chan_status

[lightning.engineering/router/update-chan-status](https://lightning.engineering/api-docs/api/lnd/router/update-chan-status/index.html)

```ruby
client.router.update_chan_status(
  { chan_point: nil,
    action: :ENABLE }
)
```

### x_import_mission_control

[lightning.engineering/router/x-import-mission-control](https://lightning.engineering/api-docs/api/lnd/router/x-import-mission-control/index.html)

```ruby
client.router.x_import_mission_control(
  { pairs: [],
    force: false }
)
```

<!-- [INJECT:GRP:DOCS] -->

_________________

<center>
  lnd-client 0.0.8
  |
  <a href="https://github.com/icebaker/lnd-client" rel="noopener noreferrer" target="_blank">GitHub</a>
  |
  <a href="https://rubygems.org/gems/lnd-client" rel="noopener noreferrer" target="_blank">RubyGems</a>
</center>
