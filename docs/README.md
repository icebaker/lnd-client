> Ruby Lightning Network Daemon (lnd) Client

Straightforward access to [lnd](https://github.com/lightningnetwork/lnd) [gRPC API](https://lightning.engineering/api-docs/api/lnd/#grpc)

This is a low-level client library. For a better experience, you may want to check out the [Lighstorm](https://github.com/icebaker/lighstorm) abstraction.

# Getting Started

## Usage

Add to your `Gemfile`:
```ruby
gem 'lnd-client', '~> 0.0.9'
```

```ruby
require 'lnd-client'

puts LNDClient.version # => 0.0.9

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

puts LNDClient.version # => 0.0.9

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

gem push lnd-client-0.0.9.gem
```

# Services

## All Services

<!-- [INJECT:GRP:INDEX] -->

- [autopilot](?id=autopilot)
- [chain_kit](?id=chain_kit)
- [chain_notifier](?id=chain_notifier)
- [dev](?id=dev)
- [invoices](?id=invoices)
- [lightning](?id=lightning)
- [neutrino_kit](?id=neutrino_kit)
- [peers](?id=peers)
- [router](?id=router)
- [signer](?id=signer)
- [state](?id=state)
- [versioner](?id=versioner)
- [wallet_kit](?id=wallet_kit)
- [wallet_unlocker](?id=wallet_unlocker)
- [watchtower](?id=watchtower)
- [watchtower_client](?id=watchtower_client)

<!-- [INJECT:GRP:INDEX] -->

<!-- [INJECT:GRP:DOCS] -->

## autopilot

### modify_status

[lightning.engineering/autopilot/modify-status](https://lightning.engineering/api-docs/api/lnd/autopilot/modify-status/index.html)

```ruby
client.autopilot.modify_status(
  { enable: false }
)
```

### query_scores

[lightning.engineering/autopilot/query-scores](https://lightning.engineering/api-docs/api/lnd/autopilot/query-scores/index.html)

```ruby
client.autopilot.query_scores(
  { pubkeys: [],
    ignore_local_state: false }
)
```

Output:
```ruby
{ results: [] }
```

### set_scores

[lightning.engineering/autopilot/set-scores](https://lightning.engineering/api-docs/api/lnd/autopilot/set-scores/index.html)

```ruby
client.autopilot.set_scores(
  { heuristic: '',
    scores: {} }
)
```

### status

[lightning.engineering/autopilot/status](https://lightning.engineering/api-docs/api/lnd/autopilot/status/index.html)

```ruby
client.autopilot.status
```

Output:
```ruby
{ active: false }
```
## chain_kit

### get_best_block

[lightning.engineering/chain-kit/get-best-block](https://lightning.engineering/api-docs/api/lnd/chain-kit/get-best-block/index.html)

```ruby
client.chain_kit.get_best_block
```

Output:
```ruby
{ block_hash: '',
  block_height: 0 }
```

### get_block

[lightning.engineering/chain-kit/get-block](https://lightning.engineering/api-docs/api/lnd/chain-kit/get-block/index.html)

```ruby
client.chain_kit.get_block(
  { block_hash: '' }
)
```

Output:
```ruby
{ raw_block: '' }
```

### get_block_hash

[lightning.engineering/chain-kit/get-block-hash](https://lightning.engineering/api-docs/api/lnd/chain-kit/get-block-hash/index.html)

```ruby
client.chain_kit.get_block_hash(
  { block_height: 0 }
)
```

Output:
```ruby
{ block_hash: '' }
```

### get_block_header

[lightning.engineering/chain-kit/get-block-header](https://lightning.engineering/api-docs/api/lnd/chain-kit/get-block-header/index.html)

```ruby
client.chain_kit.get_block_header(
  { block_hash: '' }
)
```

Output:
```ruby
{ raw_block_header: '' }
```
## chain_notifier

### register_block_epoch_ntfn

[lightning.engineering/chain-notifier/register-block-epoch-ntfn](https://lightning.engineering/api-docs/api/lnd/chain-notifier/register-block-epoch-ntfn/index.html)

```ruby
client.chain_notifier.register_block_epoch_ntfn(
  { hash: '',
    height: 0 }
)
```

### register_confirmations_ntfn

[lightning.engineering/chain-notifier/register-confirmations-ntfn](https://lightning.engineering/api-docs/api/lnd/chain-notifier/register-confirmations-ntfn/index.html)

```ruby
client.chain_notifier.register_confirmations_ntfn(
  { txid: '',
    script: '',
    num_confs: 0,
    height_hint: 0,
    include_block: false }
)
```

### register_spend_ntfn

[lightning.engineering/chain-notifier/register-spend-ntfn](https://lightning.engineering/api-docs/api/lnd/chain-notifier/register-spend-ntfn/index.html)

```ruby
client.chain_notifier.register_spend_ntfn(
  { outpoint: nil,
    script: '',
    height_hint: 0 }
)
```
## dev

### import_graph

[lightning.engineering/dev/import-graph](https://lightning.engineering/api-docs/api/lnd/dev/import-graph/index.html)

```ruby
client.dev.import_graph(
  { nodes: [],
    edges: [] }
)
```
## invoices

### add_hold_invoice

[lightning.engineering/invoices/add-hold-invoice](https://lightning.engineering/api-docs/api/lnd/invoices/add-hold-invoice/index.html)

```ruby
client.invoices.add_hold_invoice(
  { memo: '',
    hash: '',
    value: 0,
    value_msat: 0,
    description_hash: '',
    expiry: 0,
    fallback_addr: '',
    cltv_expiry: 0,
    route_hints: [],
    private: false }
)
```

Output:
```ruby
{ payment_request: '',
  add_index: 0,
  payment_addr: '' }
```

### cancel_invoice

[lightning.engineering/invoices/cancel-invoice](https://lightning.engineering/api-docs/api/lnd/invoices/cancel-invoice/index.html)

```ruby
client.invoices.cancel_invoice(
  { payment_hash: '' }
)
```

### lookup_invoice_v2

[lightning.engineering/invoices/lookup-invoice-v2](https://lightning.engineering/api-docs/api/lnd/invoices/lookup-invoice-v2/index.html)

```ruby
client.invoices.lookup_invoice_v2(
  { lookup_modifier: :DEFAULT,
    payment_hash: '',
    payment_addr: '',
    set_id: '' }
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

### settle_invoice

[lightning.engineering/invoices/settle-invoice](https://lightning.engineering/api-docs/api/lnd/invoices/settle-invoice/index.html)

```ruby
client.invoices.settle_invoice(
  { preimage: '' }
)
```

### subscribe_single_invoice

[lightning.engineering/invoices/subscribe-single-invoice](https://lightning.engineering/api-docs/api/lnd/invoices/subscribe-single-invoice/index.html)

```ruby
client.invoices.subscribe_single_invoice(
  { r_hash: '' }
) do |data|
  puts data.inspect # => { ... }
end
```
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
  require_htlc_interceptor: false,
  store_final_htlc_resolutions: false }
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
    peer: '',
    peer_alias_lookup: false }
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

### lookup_htlc_resolution

[lightning.engineering/lightning/lookup-htlc-resolution](https://lightning.engineering/api-docs/api/lnd/lightning/lookup-htlc-resolution/index.html)

```ruby
client.lightning.lookup_htlc_resolution(
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
    remote_chan_reserve_sat: 0,
    fund_max: false,
    memo: '',
    outpoints: [] }
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
    remote_chan_reserve_sat: 0,
    fund_max: false,
    memo: '',
    outpoints: [] }
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
    blinded_payment_paths: [],
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
client.lightning.wallet_balance(
  { account: '' }
)
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
## neutrino_kit

### add_peer

[lightning.engineering/neutrino-kit/add-peer](https://lightning.engineering/api-docs/api/lnd/neutrino-kit/add-peer/index.html)

```ruby
client.neutrino_kit.add_peer(
  { peer_addrs: '' }
)
```

### disconnect_peer

[lightning.engineering/neutrino-kit/disconnect-peer](https://lightning.engineering/api-docs/api/lnd/neutrino-kit/disconnect-peer/index.html)

```ruby
client.neutrino_kit.disconnect_peer(
  { peer_addrs: '' }
)
```

### get_block

[lightning.engineering/neutrino-kit/get-block](https://lightning.engineering/api-docs/api/lnd/neutrino-kit/get-block/index.html)

```ruby
client.neutrino_kit.get_block(
  { hash: '' }
)
```

Output:
```ruby
{ hash: '',
  confirmations: 0,
  stripped_size: 0,
  size: 0,
  weight: 0,
  height: 0,
  version: 0,
  version_hex: '',
  merkleroot: '',
  tx: [],
  time: 0,
  nonce: 0,
  bits: '',
  ntx: 0,
  previous_block_hash: '',
  raw_hex: '' }
```

### get_block_hash

[lightning.engineering/neutrino-kit/get-block-hash](https://lightning.engineering/api-docs/api/lnd/neutrino-kit/get-block-hash/index.html)

```ruby
client.neutrino_kit.get_block_hash(
  { height: 0 }
)
```

Output:
```ruby
{ hash: '' }
```

### get_block_header

[lightning.engineering/neutrino-kit/get-block-header](https://lightning.engineering/api-docs/api/lnd/neutrino-kit/get-block-header/index.html)

```ruby
client.neutrino_kit.get_block_header(
  { hash: '' }
)
```

Output:
```ruby
{ hash: '',
  confirmations: 0,
  stripped_size: 0,
  size: 0,
  weight: 0,
  height: 0,
  version: 0,
  version_hex: '',
  merkleroot: '',
  time: 0,
  nonce: 0,
  bits: '',
  ntx: 0,
  previous_block_hash: '',
  raw_hex: '' }
```

### get_c_filter

[lightning.engineering/neutrino-kit/get-c-filter](https://lightning.engineering/api-docs/api/lnd/neutrino-kit/get-c-filter/index.html)

```ruby
client.neutrino_kit.get_c_filter(
  { hash: '' }
)
```

Output:
```ruby
{ filter: '' }
```

### is_banned

[lightning.engineering/neutrino-kit/is-banned](https://lightning.engineering/api-docs/api/lnd/neutrino-kit/is-banned/index.html)

```ruby
client.neutrino_kit.is_banned(
  { peer_addrs: '' }
)
```

Output:
```ruby
{ banned: false }
```

### status

[lightning.engineering/neutrino-kit/status](https://lightning.engineering/api-docs/api/lnd/neutrino-kit/status/index.html)

```ruby
client.neutrino_kit.status
```

Output:
```ruby
{ active: false,
  synced: false,
  block_height: 0,
  block_hash: '',
  peers: [] }
```
## peers

### update_node_announcement

[lightning.engineering/peers/update-node-announcement](https://lightning.engineering/api-docs/api/lnd/peers/update-node-announcement/index.html)

```ruby
client.peers.update_node_announcement(
  { feature_updates: [],
    color: '',
    alias: '',
    address_updates: [] }
)
```

Output:
```ruby
{ ops: [] }
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
## signer

### compute_input_script

[lightning.engineering/signer/compute-input-script](https://lightning.engineering/api-docs/api/lnd/signer/compute-input-script/index.html)

```ruby
client.signer.compute_input_script(
  { raw_tx_bytes: '',
    sign_descs: [],
    prev_outputs: [] }
)
```

Output:
```ruby
{ input_scripts: [] }
```

### derive_shared_key

[lightning.engineering/signer/derive-shared-key](https://lightning.engineering/api-docs/api/lnd/signer/derive-shared-key/index.html)

```ruby
client.signer.derive_shared_key(
  { ephemeral_pubkey: '',
    key_loc: nil,
    key_desc: nil }
)
```

Output:
```ruby
{ shared_key: '' }
```

### mu_sig2_cleanup

[lightning.engineering/signer/mu-sig2-cleanup](https://lightning.engineering/api-docs/api/lnd/signer/mu-sig2-cleanup/index.html)

```ruby
client.signer.mu_sig2_cleanup(
  { session_id: '' }
)
```

### mu_sig2_combine_keys

[lightning.engineering/signer/mu-sig2-combine-keys](https://lightning.engineering/api-docs/api/lnd/signer/mu-sig2-combine-keys/index.html)

```ruby
client.signer.mu_sig2_combine_keys(
  { all_signer_pubkeys: [],
    tweaks: [],
    taproot_tweak: nil,
    version: :MUSIG2_VERSION_UNDEFINED }
)
```

Output:
```ruby
{ combined_key: '',
  taproot_internal_key: '',
  version: :MUSIG2_VERSION_UNDEFINED }
```

### mu_sig2_combine_sig

[lightning.engineering/signer/mu-sig2-combine-sig](https://lightning.engineering/api-docs/api/lnd/signer/mu-sig2-combine-sig/index.html)

```ruby
client.signer.mu_sig2_combine_sig(
  { session_id: '',
    other_partial_signatures: [] }
)
```

Output:
```ruby
{ have_all_signatures: false,
  final_signature: '' }
```

### mu_sig2_create_session

[lightning.engineering/signer/mu-sig2-create-session](https://lightning.engineering/api-docs/api/lnd/signer/mu-sig2-create-session/index.html)

```ruby
client.signer.mu_sig2_create_session(
  { key_loc: nil,
    all_signer_pubkeys: [],
    other_signer_public_nonces: [],
    tweaks: [],
    taproot_tweak: nil,
    version: :MUSIG2_VERSION_UNDEFINED,
    pregenerated_local_nonce: '' }
)
```

Output:
```ruby
{ session_id: '',
  combined_key: '',
  taproot_internal_key: '',
  local_public_nonces: '',
  have_all_nonces: false,
  version: :MUSIG2_VERSION_UNDEFINED }
```

### mu_sig2_register_nonces

[lightning.engineering/signer/mu-sig2-register-nonces](https://lightning.engineering/api-docs/api/lnd/signer/mu-sig2-register-nonces/index.html)

```ruby
client.signer.mu_sig2_register_nonces(
  { session_id: '',
    other_signer_public_nonces: [] }
)
```

Output:
```ruby
{ have_all_nonces: false }
```

### mu_sig2_sign

[lightning.engineering/signer/mu-sig2-sign](https://lightning.engineering/api-docs/api/lnd/signer/mu-sig2-sign/index.html)

```ruby
client.signer.mu_sig2_sign(
  { session_id: '',
    message_digest: '',
    cleanup: false }
)
```

Output:
```ruby
{ local_partial_signature: '' }
```

### sign_message

[lightning.engineering/signer/sign-message](https://lightning.engineering/api-docs/api/lnd/signer/sign-message/index.html)

```ruby
client.signer.sign_message(
  { msg: '',
    key_loc: nil,
    double_hash: false,
    compact_sig: false,
    schnorr_sig: false,
    schnorr_sig_tap_tweak: '',
    tag: '' }
)
```

Output:
```ruby
{ signature: '' }
```

### sign_output_raw

[lightning.engineering/signer/sign-output-raw](https://lightning.engineering/api-docs/api/lnd/signer/sign-output-raw/index.html)

```ruby
client.signer.sign_output_raw(
  { raw_tx_bytes: '',
    sign_descs: [],
    prev_outputs: [] }
)
```

Output:
```ruby
{ raw_sigs: [] }
```

### verify_message

[lightning.engineering/signer/verify-message](https://lightning.engineering/api-docs/api/lnd/signer/verify-message/index.html)

```ruby
client.signer.verify_message(
  { msg: '',
    signature: '',
    pubkey: '',
    is_schnorr_sig: false,
    tag: '' }
)
```

Output:
```ruby
{ valid: false }
```
## state

### get_state

[lightning.engineering/state/get-state](https://lightning.engineering/api-docs/api/lnd/state/get-state/index.html)

```ruby
client.state.get_state
```

Output:
```ruby
{ state: :NON_EXISTING }
```

### subscribe_state

[lightning.engineering/state/subscribe-state](https://lightning.engineering/api-docs/api/lnd/state/subscribe-state/index.html)

```ruby
client.state.subscribe_state do |data|
  puts data.inspect # => { ... }
end
```
## versioner

### get_version

[lightning.engineering/versioner/get-version](https://lightning.engineering/api-docs/api/lnd/versioner/get-version/index.html)

```ruby
client.versioner.get_version
```

Output:
```ruby
{ commit: '',
  commit_hash: '',
  version: '',
  app_major: 0,
  app_minor: 0,
  app_patch: 0,
  app_pre_release: '',
  build_tags: [],
  go_version: '' }
```
## wallet_kit

### bump_fee

[lightning.engineering/wallet-kit/bump-fee](https://lightning.engineering/api-docs/api/lnd/wallet-kit/bump-fee/index.html)

```ruby
client.wallet_kit.bump_fee(
  { outpoint: nil,
    target_conf: 0,
    sat_per_byte: 0,
    force: false,
    sat_per_vbyte: 0 }
)
```

### derive_key

[lightning.engineering/wallet-kit/derive-key](https://lightning.engineering/api-docs/api/lnd/wallet-kit/derive-key/index.html)

```ruby
client.wallet_kit.derive_key(
  { key_family: 0,
    key_index: 0 }
)
```

Output:
```ruby
{ raw_key_bytes: '',
  key_loc: nil }
```

### derive_next_key

[lightning.engineering/wallet-kit/derive-next-key](https://lightning.engineering/api-docs/api/lnd/wallet-kit/derive-next-key/index.html)

```ruby
client.wallet_kit.derive_next_key(
  { key_finger_print: 0,
    key_family: 0 }
)
```

Output:
```ruby
{ raw_key_bytes: '',
  key_loc: nil }
```

### estimate_fee

[lightning.engineering/wallet-kit/estimate-fee](https://lightning.engineering/api-docs/api/lnd/wallet-kit/estimate-fee/index.html)

```ruby
client.wallet_kit.estimate_fee(
  { conf_target: 0 }
)
```

Output:
```ruby
{ sat_per_kw: 0 }
```

### finalize_psbt

[lightning.engineering/wallet-kit/finalize-psbt](https://lightning.engineering/api-docs/api/lnd/wallet-kit/finalize-psbt/index.html)

```ruby
client.wallet_kit.finalize_psbt(
  { funded_psbt: '',
    account: '' }
)
```

Output:
```ruby
{ signed_psbt: '',
  raw_final_tx: '' }
```

### fund_psbt

[lightning.engineering/wallet-kit/fund-psbt](https://lightning.engineering/api-docs/api/lnd/wallet-kit/fund-psbt/index.html)

```ruby
client.wallet_kit.fund_psbt(
  { account: '',
    min_confs: 0,
    spend_unconfirmed: false,
    change_type: :CHANGE_ADDRESS_TYPE_UNSPECIFIED,
    psbt: '',
    raw: nil,
    target_conf: 0,
    sat_per_vbyte: 0 }
)
```

Output:
```ruby
{ funded_psbt: '',
  change_output_index: 0,
  locked_utxos: [] }
```

### import_account

[lightning.engineering/wallet-kit/import-account](https://lightning.engineering/api-docs/api/lnd/wallet-kit/import-account/index.html)

```ruby
client.wallet_kit.import_account(
  { name: '',
    extended_public_key: '',
    master_key_fingerprint: '',
    address_type: :UNKNOWN,
    dry_run: false }
)
```

Output:
```ruby
{ account: nil,
  dry_run_external_addrs: [],
  dry_run_internal_addrs: [] }
```

### import_public_key

[lightning.engineering/wallet-kit/import-public-key](https://lightning.engineering/api-docs/api/lnd/wallet-kit/import-public-key/index.html)

```ruby
client.wallet_kit.import_public_key(
  { public_key: '',
    address_type: :UNKNOWN }
)
```

### import_tapscript

[lightning.engineering/wallet-kit/import-tapscript](https://lightning.engineering/api-docs/api/lnd/wallet-kit/import-tapscript/index.html)

```ruby
client.wallet_kit.import_tapscript(
  { internal_public_key: '',
    full_tree: nil,
    partial_reveal: nil,
    root_hash_only: '',
    full_key_only: false }
)
```

Output:
```ruby
{ p2tr_address: '' }
```

### label_transaction

[lightning.engineering/wallet-kit/label-transaction](https://lightning.engineering/api-docs/api/lnd/wallet-kit/label-transaction/index.html)

```ruby
client.wallet_kit.label_transaction(
  { txid: '',
    label: '',
    overwrite: false }
)
```

### lease_output

[lightning.engineering/wallet-kit/lease-output](https://lightning.engineering/api-docs/api/lnd/wallet-kit/lease-output/index.html)

```ruby
client.wallet_kit.lease_output(
  { id: '',
    outpoint: nil,
    expiration_seconds: 0 }
)
```

Output:
```ruby
{ expiration: 0 }
```

### list_accounts

[lightning.engineering/wallet-kit/list-accounts](https://lightning.engineering/api-docs/api/lnd/wallet-kit/list-accounts/index.html)

```ruby
client.wallet_kit.list_accounts(
  { name: '',
    address_type: :UNKNOWN }
)
```

Output:
```ruby
{ accounts: [] }
```

### list_addresses

[lightning.engineering/wallet-kit/list-addresses](https://lightning.engineering/api-docs/api/lnd/wallet-kit/list-addresses/index.html)

```ruby
client.wallet_kit.list_addresses(
  { account_name: '',
    show_custom_accounts: false }
)
```

Output:
```ruby
{ account_with_addresses: [] }
```

### list_leases

[lightning.engineering/wallet-kit/list-leases](https://lightning.engineering/api-docs/api/lnd/wallet-kit/list-leases/index.html)

```ruby
client.wallet_kit.list_leases
```

Output:
```ruby
{ locked_utxos: [] }
```

### list_sweeps

[lightning.engineering/wallet-kit/list-sweeps](https://lightning.engineering/api-docs/api/lnd/wallet-kit/list-sweeps/index.html)

```ruby
client.wallet_kit.list_sweeps(
  { verbose: false }
)
```

Output:
```ruby
{ transaction_details: nil,
  transaction_ids: nil }
```

### list_unspent

[lightning.engineering/wallet-kit/list-unspent](https://lightning.engineering/api-docs/api/lnd/wallet-kit/list-unspent/index.html)

```ruby
client.wallet_kit.list_unspent(
  { min_confs: 0,
    max_confs: 0,
    account: '',
    unconfirmed_only: false }
)
```

Output:
```ruby
{ utxos: [] }
```

### next_addr

[lightning.engineering/wallet-kit/next-addr](https://lightning.engineering/api-docs/api/lnd/wallet-kit/next-addr/index.html)

```ruby
client.wallet_kit.next_addr(
  { account: '',
    type: :UNKNOWN,
    change: false }
)
```

Output:
```ruby
{ addr: '' }
```

### pending_sweeps

[lightning.engineering/wallet-kit/pending-sweeps](https://lightning.engineering/api-docs/api/lnd/wallet-kit/pending-sweeps/index.html)

```ruby
client.wallet_kit.pending_sweeps
```

Output:
```ruby
{ pending_sweeps: [] }
```

### publish_transaction

[lightning.engineering/wallet-kit/publish-transaction](https://lightning.engineering/api-docs/api/lnd/wallet-kit/publish-transaction/index.html)

```ruby
client.wallet_kit.publish_transaction(
  { tx_hex: '',
    label: '' }
)
```

Output:
```ruby
{ publish_error: '' }
```

### release_output

[lightning.engineering/wallet-kit/release-output](https://lightning.engineering/api-docs/api/lnd/wallet-kit/release-output/index.html)

```ruby
client.wallet_kit.release_output(
  { id: '',
    outpoint: nil }
)
```

### required_reserve

[lightning.engineering/wallet-kit/required-reserve](https://lightning.engineering/api-docs/api/lnd/wallet-kit/required-reserve/index.html)

```ruby
client.wallet_kit.required_reserve(
  { additional_public_channels: 0 }
)
```

Output:
```ruby
{ required_reserve: 0 }
```

### send_outputs

[lightning.engineering/wallet-kit/send-outputs](https://lightning.engineering/api-docs/api/lnd/wallet-kit/send-outputs/index.html)

```ruby
client.wallet_kit.send_outputs(
  { sat_per_kw: 0,
    outputs: [],
    label: '',
    min_confs: 0,
    spend_unconfirmed: false }
)
```

Output:
```ruby
{ raw_tx: '' }
```

### sign_message_with_addr

[lightning.engineering/wallet-kit/sign-message-with-addr](https://lightning.engineering/api-docs/api/lnd/wallet-kit/sign-message-with-addr/index.html)

```ruby
client.wallet_kit.sign_message_with_addr(
  { msg: '',
    addr: '' }
)
```

Output:
```ruby
{ signature: '' }
```

### sign_psbt

[lightning.engineering/wallet-kit/sign-psbt](https://lightning.engineering/api-docs/api/lnd/wallet-kit/sign-psbt/index.html)

```ruby
client.wallet_kit.sign_psbt(
  { funded_psbt: '' }
)
```

Output:
```ruby
{ signed_psbt: '',
  signed_inputs: [] }
```

### verify_message_with_addr

[lightning.engineering/wallet-kit/verify-message-with-addr](https://lightning.engineering/api-docs/api/lnd/wallet-kit/verify-message-with-addr/index.html)

```ruby
client.wallet_kit.verify_message_with_addr(
  { msg: '',
    signature: '',
    addr: '' }
)
```

Output:
```ruby
{ valid: false,
  pubkey: '' }
```
## wallet_unlocker

### change_password

[lightning.engineering/wallet-unlocker/change-password](https://lightning.engineering/api-docs/api/lnd/wallet-unlocker/change-password/index.html)

```ruby
client.wallet_unlocker.change_password(
  { current_password: '',
    new_password: '',
    stateless_init: false,
    new_macaroon_root_key: false }
)
```

Output:
```ruby
{ admin_macaroon: '' }
```

### gen_seed

[lightning.engineering/wallet-unlocker/gen-seed](https://lightning.engineering/api-docs/api/lnd/wallet-unlocker/gen-seed/index.html)

```ruby
client.wallet_unlocker.gen_seed(
  { aezeed_passphrase: '',
    seed_entropy: '' }
)
```

Output:
```ruby
{ cipher_seed_mnemonic: [],
  enciphered_seed: '' }
```

### init_wallet

[lightning.engineering/wallet-unlocker/init-wallet](https://lightning.engineering/api-docs/api/lnd/wallet-unlocker/init-wallet/index.html)

```ruby
client.wallet_unlocker.init_wallet(
  { wallet_password: '',
    cipher_seed_mnemonic: [],
    aezeed_passphrase: '',
    recovery_window: 0,
    channel_backups: nil,
    stateless_init: false,
    extended_master_key: '',
    extended_master_key_birthday_timestamp: 0,
    watch_only: nil,
    macaroon_root_key: '' }
)
```

Output:
```ruby
{ admin_macaroon: '' }
```

### unlock_wallet

[lightning.engineering/wallet-unlocker/unlock-wallet](https://lightning.engineering/api-docs/api/lnd/wallet-unlocker/unlock-wallet/index.html)

```ruby
client.wallet_unlocker.unlock_wallet(
  { wallet_password: '',
    recovery_window: 0,
    channel_backups: nil,
    stateless_init: false }
)
```
## watchtower

### get_info

[lightning.engineering/watchtower/get-info](https://lightning.engineering/api-docs/api/lnd/watchtower/get-info/index.html)

```ruby
client.watchtower.get_info
```

Output:
```ruby
{ pubkey: '',
  listeners: [],
  uris: [] }
```
## watchtower_client

### add_tower

[lightning.engineering/watchtower-client/add-tower](https://lightning.engineering/api-docs/api/lnd/watchtower-client/add-tower/index.html)

```ruby
client.watchtower_client.add_tower(
  { pubkey: '',
    address: '' }
)
```

### get_tower_info

[lightning.engineering/watchtower-client/get-tower-info](https://lightning.engineering/api-docs/api/lnd/watchtower-client/get-tower-info/index.html)

```ruby
client.watchtower_client.get_tower_info(
  { pubkey: '',
    include_sessions: false,
    exclude_exhausted_sessions: false }
)
```

Output:
```ruby
{ pubkey: '',
  addresses: [],
  active_session_candidate: false,
  num_sessions: 0,
  sessions: [],
  session_info: [] }
```

### list_towers

[lightning.engineering/watchtower-client/list-towers](https://lightning.engineering/api-docs/api/lnd/watchtower-client/list-towers/index.html)

```ruby
client.watchtower_client.list_towers(
  { include_sessions: false,
    exclude_exhausted_sessions: false }
)
```

Output:
```ruby
{ towers: [] }
```

### policy

[lightning.engineering/watchtower-client/policy](https://lightning.engineering/api-docs/api/lnd/watchtower-client/policy/index.html)

```ruby
client.watchtower_client.policy(
  { policy_type: :LEGACY }
)
```

Output:
```ruby
{ max_updates: 0,
  sweep_sat_per_byte: 0,
  sweep_sat_per_vbyte: 0 }
```

### remove_tower

[lightning.engineering/watchtower-client/remove-tower](https://lightning.engineering/api-docs/api/lnd/watchtower-client/remove-tower/index.html)

```ruby
client.watchtower_client.remove_tower(
  { pubkey: '',
    address: '' }
)
```

### stats

[lightning.engineering/watchtower-client/stats](https://lightning.engineering/api-docs/api/lnd/watchtower-client/stats/index.html)

```ruby
client.watchtower_client.stats
```

Output:
```ruby
{ num_backups: 0,
  num_pending_backups: 0,
  num_failed_backups: 0,
  num_sessions_acquired: 0,
  num_sessions_exhausted: 0 }
```

<!-- [INJECT:GRP:DOCS] -->

_________________

<center>
  lnd-client 0.0.9
  |
  <a href="https://github.com/icebaker/lnd-client" rel="noopener noreferrer" target="_blank">GitHub</a>
  |
  <a href="https://rubygems.org/gems/lnd-client" rel="noopener noreferrer" target="_blank">RubyGems</a>
</center>
