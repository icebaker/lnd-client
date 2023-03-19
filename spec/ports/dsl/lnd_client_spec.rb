# frozen_string_literal: true

require_relative '../../../ports/dsl/lnd-client'

RSpec.describe LNDClient do
  describe '.new' do
    context 'lndconnect' do
      let(:key) { 'lndconnect' }

      it 'creates a valid connection' do
        client = described_class.new(
          'lndconnect://127.0.0.1:10001?cert=MIICJzCCAc2gAwIBAgIRAImZs0ieSBjBcMtpD8oQ_okwCgYIKoZIzj0EAwIwMTEfMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEOMAwGA1UEAxMFYWxpY2UwHhcNMjMwMzEyMjM0NDEyWhcNMjQwNTA2MjM0NDEyWjAxMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MQ4wDAYDVQQDEwVhbGljZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABL8ZHtjXzSy7Qs9SL0wECTsAwyX8xplEox1DQUMnB6mfu5dXxzuTqoyCL1FuwjthqfZNO3hX2O-o5pyHxGkqYA2jgcUwgcIwDgYDVR0PAQH_BAQDAgKkMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA8GA1UdEwEB_wQFMAMBAf8wHQYDVR0OBBYEFFXs5yUhjbRfmlYGGEYPlzquQdslMGsGA1UdEQRkMGKCBWFsaWNlgglsb2NhbGhvc3SCBWFsaWNlgg5wb2xhci1uMS1hbGljZYIEdW5peIIKdW5peHBhY2tldIIHYnVmY29ubocEfwAAAYcQAAAAAAAAAAAAAAAAAAAAAYcErBgABjAKBggqhkjOPQQDAgNIADBFAiBvz_hKoN0JltWgjzBHYHpB4fM2tqPge9j1m1tt0ye8PgIhAJkGw-5chEuH5bVFLBQjo5SUAW_sGX9i0aSqcSJBEERQ&macaroon=AgEDbG5kAvgBAwoQZfbno2BCpVfn-g6USaC3JRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYg61atst43JqOPEZKGrLszr6q8eWVvQfxgr1inv45ukJ4'
        )

        expect(
          VCR.reel.replay('dsl.wallet_balance.total_balance', as: "alice/#{key}") do
            client.lightning.wallet_balance.total_balance
          end
        ).to eq(483_526)
      end
    end

    context 'path' do
      let(:key) { 'path' }

      it 'creates a valid connection' do
        client = described_class.new(
          address: '127.0.0.1:10001',
          certificate_path: '/home/icebaker/.polar/networks/1/volumes/lnd/alice/tls.cert',
          macaroon_path: '/home/icebaker/.polar/networks/1/volumes/lnd/alice/data/chain/bitcoin/regtest/admin.macaroon'
        ) do |read, path|
          VCR.reel.replay('File.read', path: path) { read.call }
        end

        expect(
          VCR.reel.replay('dsl.wallet_balance.total_balance', as: "alice/#{key}") do
            client.lightning.wallet_balance.total_balance
          end
        ).to eq(483_526)
      end
    end

    context 'base64' do
      let(:key) { 'base64' }

      it 'creates a valid connection' do
        client = described_class.new(
          host: '127.0.0.1',
          port: 10_001,
          certificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNKekNDQWMyZ0F3SUJBZ0lSQUltWnMwaWVTQmpCY010cEQ4b1Evb2t3Q2dZSUtvWkl6ajBFQXdJd01URWYKTUIwR0ExVUVDaE1XYkc1a0lHRjFkRzluWlc1bGNtRjBaV1FnWTJWeWRERU9NQXdHQTFVRUF4TUZZV3hwWTJVdwpIaGNOTWpNd016RXlNak0wTkRFeVdoY05NalF3TlRBMk1qTTBOREV5V2pBeE1SOHdIUVlEVlFRS0V4WnNibVFnCllYVjBiMmRsYm1WeVlYUmxaQ0JqWlhKME1RNHdEQVlEVlFRREV3VmhiR2xqWlRCWk1CTUdCeXFHU000OUFnRUcKQ0NxR1NNNDlBd0VIQTBJQUJMOFpIdGpYelN5N1FzOVNMMHdFQ1RzQXd5WDh4cGxFb3gxRFFVTW5CNm1mdTVkWAp4enVUcW95Q0wxRnV3anRocWZaTk8zaFgyTytvNXB5SHhHa3FZQTJqZ2NVd2djSXdEZ1lEVlIwUEFRSC9CQVFECkFnS2tNQk1HQTFVZEpRUU1NQW9HQ0NzR0FRVUZCd01CTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3SFFZRFZSME8KQkJZRUZGWHM1eVVoamJSZm1sWUdHRVlQbHpxdVFkc2xNR3NHQTFVZEVRUmtNR0tDQldGc2FXTmxnZ2xzYjJOaApiR2h2YzNTQ0JXRnNhV05sZ2c1d2IyeGhjaTF1TVMxaGJHbGpaWUlFZFc1cGVJSUtkVzVwZUhCaFkydGxkSUlIClluVm1ZMjl1Ym9jRWZ3QUFBWWNRQUFBQUFBQUFBQUFBQUFBQUFBQUFBWWNFckJnQUJqQUtCZ2dxaGtqT1BRUUQKQWdOSUFEQkZBaUJ2ei9oS29OMEpsdFdnanpCSFlIcEI0Zk0ydHFQZ2U5ajFtMXR0MHllOFBnSWhBSmtHdys1YwpoRXVINWJWRkxCUWpvNVNVQVcvc0dYOWkwYVNxY1NKQkVFUlEKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=',
          macaroon: 'AgEDbG5kAvgBAwoQZfbno2BCpVfn+g6USaC3JRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYg61atst43JqOPEZKGrLszr6q8eWVvQfxgr1inv45ukJ4='
        )

        expect(
          VCR.reel.replay('dsl.wallet_balance.total_balance', as: "alice/#{key}") do
            client.lightning.wallet_balance.total_balance
          end
        ).to eq(483_526)
      end
    end

    context 'hex' do
      let(:key) { 'hex' }

      it 'creates a valid connection' do
        client = described_class.new(
          host: '127.0.0.1',
          port: 10_001,
          certificate: '2d2d2d2d2d424547494e2043455254494649434154452d2d2d2d2d0a4d4949434a7a434341633267417749424167495241496d5a7330696553426a42634d747044386f512f6f6b77436759494b6f5a497a6a3045417749774d5445660a4d4230474131554543684d576247356b494746316447396e5a57356c636d46305a575167593256796444454f4d4177474131554541784d4659577870593255770a4868634e4d6a4d774d7a45794d6a4d304e4445795768634e4d6a51774e5441324d6a4d304e444579576a41784d523877485159445651514b45785a73626d51670a595856306232646c626d56795958526c5a43426a5a584a304d51347744415944565151444577566862476c6a5a54425a4d424d4742797147534d3439416745470a43437147534d34394177454841304941424c385a48746a587a537937517339534c307745435473417779583878706c456f78314451554d6e42366d66753564580a787a7554716f79434c314675776a746871665a4e4f336858324f2b6f3570794878476b715941326a676355776763497744675944565230504151482f424151440a41674b6b4d424d47413155644a51514d4d416f47434373474151554642774d424d41384741315564457745422f7751464d414d4241663877485159445652304f0a4242594546465873357955686a6252666d6c5947474559506c7a71755164736c4d477347413155644551526b4d474b434257467361574e6c67676c7362324e680a62476876633353434257467361574e6c6767357762327868636931754d53316862476c6a5a594945645735706549494b64573570654842685932746c644949480a596e566d59323975626f6345667741414159635141414141414141414141414141414141414141414159634572426741426a414b42676771686b6a4f505151440a41674e4941444246416942767a2f684b6f4e304a6c7457676a7a42485948704234664d327471506765396a316d3174743079653850674968414a6b47772b35630a68457548356256464c42516a6f35535541572f73475839693061537163534a42454552510a2d2d2d2d2d454e442043455254494649434154452d2d2d2d2d0a',
          macaroon: '0201036c6e6402f801030a1065f6e7a36042a557e7fa0e9449a0b7251201301a160a0761646472657373120472656164120577726974651a130a04696e666f120472656164120577726974651a170a08696e766f69636573120472656164120577726974651a210a086d616361726f6f6e120867656e6572617465120472656164120577726974651a160a076d657373616765120472656164120577726974651a170a086f6666636861696e120472656164120577726974651a160a076f6e636861696e120472656164120577726974651a140a057065657273120472656164120577726974651a180a067369676e6572120867656e657261746512047265616400000620eb56adb2de3726a38f119286acbb33afaabc79656f41fc60af58a7bf8e6e909e'
        )

        expect(
          VCR.reel.replay('dsl.wallet_balance.total_balance', as: "alice/#{key}") do
            client.lightning.wallet_balance.total_balance
          end
        ).to eq(483_526)
      end
    end

    context 'raw' do
      let(:key) { 'raw' }

      let(:raw_certificate) do
        path = '/home/icebaker/.polar/networks/1/volumes/lnd/alice/tls.cert'
        VCR.reel.replay('File.read', path: path) { File.read(path) }
      end

      let(:raw_macaroon) do
        path = '/home/icebaker/.polar/networks/1/volumes/lnd/alice/data/chain/bitcoin/regtest/admin.macaroon'
        VCR.reel.replay('File.read', path: path) { File.read(path) }
      end

      it 'creates a valid connection' do
        client = described_class.new(
          address: '127.0.0.1:10001',
          certificate: raw_certificate,
          macaroon: raw_macaroon
        )

        expect(client.connection.keys).not_to include(:lightning)

        expect(
          VCR.reel.replay('dsl.wallet_balance.total_balance', as: "alice/#{key}") do
            client.lightning.wallet_balance.total_balance
          end
        ).to eq(483_526)
      end
    end

    context 'lndconnect channel_args' do
      let(:key) { 'lndconnect/channel_args' }

      it 'creates a valid connection' do
        client = described_class.new(
          'lndconnect://127.0.0.1:10001?cert=MIICJzCCAc2gAwIBAgIRAImZs0ieSBjBcMtpD8oQ_okwCgYIKoZIzj0EAwIwMTEfMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEOMAwGA1UEAxMFYWxpY2UwHhcNMjMwMzEyMjM0NDEyWhcNMjQwNTA2MjM0NDEyWjAxMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MQ4wDAYDVQQDEwVhbGljZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABL8ZHtjXzSy7Qs9SL0wECTsAwyX8xplEox1DQUMnB6mfu5dXxzuTqoyCL1FuwjthqfZNO3hX2O-o5pyHxGkqYA2jgcUwgcIwDgYDVR0PAQH_BAQDAgKkMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA8GA1UdEwEB_wQFMAMBAf8wHQYDVR0OBBYEFFXs5yUhjbRfmlYGGEYPlzquQdslMGsGA1UdEQRkMGKCBWFsaWNlgglsb2NhbGhvc3SCBWFsaWNlgg5wb2xhci1uMS1hbGljZYIEdW5peIIKdW5peHBhY2tldIIHYnVmY29ubocEfwAAAYcQAAAAAAAAAAAAAAAAAAAAAYcErBgABjAKBggqhkjOPQQDAgNIADBFAiBvz_hKoN0JltWgjzBHYHpB4fM2tqPge9j1m1tt0ye8PgIhAJkGw-5chEuH5bVFLBQjo5SUAW_sGX9i0aSqcSJBEERQ&macaroon=AgEDbG5kAvgBAwoQZfbno2BCpVfn-g6USaC3JRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYg61atst43JqOPEZKGrLszr6q8eWVvQfxgr1inv45ukJ4',
          lightning: { channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 } }
        )

        expect(client.connection[:lightning]).to eq(
          { channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 } }
        )

        expect(
          VCR.reel.replay('dsl.wallet_balance.total_balance', as: "alice/#{key}") do
            client.lightning.describe_graph.nodes.size
          end
        ).to eq(3)
      end
    end

    context 'base64 channel_args' do
      let(:key) { 'base64/channel_args' }

      it 'creates a valid connection' do
        client = described_class.new(
          host: '127.0.0.1',
          port: 10_001,
          certificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNKekNDQWMyZ0F3SUJBZ0lSQUltWnMwaWVTQmpCY010cEQ4b1Evb2t3Q2dZSUtvWkl6ajBFQXdJd01URWYKTUIwR0ExVUVDaE1XYkc1a0lHRjFkRzluWlc1bGNtRjBaV1FnWTJWeWRERU9NQXdHQTFVRUF4TUZZV3hwWTJVdwpIaGNOTWpNd016RXlNak0wTkRFeVdoY05NalF3TlRBMk1qTTBOREV5V2pBeE1SOHdIUVlEVlFRS0V4WnNibVFnCllYVjBiMmRsYm1WeVlYUmxaQ0JqWlhKME1RNHdEQVlEVlFRREV3VmhiR2xqWlRCWk1CTUdCeXFHU000OUFnRUcKQ0NxR1NNNDlBd0VIQTBJQUJMOFpIdGpYelN5N1FzOVNMMHdFQ1RzQXd5WDh4cGxFb3gxRFFVTW5CNm1mdTVkWAp4enVUcW95Q0wxRnV3anRocWZaTk8zaFgyTytvNXB5SHhHa3FZQTJqZ2NVd2djSXdEZ1lEVlIwUEFRSC9CQVFECkFnS2tNQk1HQTFVZEpRUU1NQW9HQ0NzR0FRVUZCd01CTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3SFFZRFZSME8KQkJZRUZGWHM1eVVoamJSZm1sWUdHRVlQbHpxdVFkc2xNR3NHQTFVZEVRUmtNR0tDQldGc2FXTmxnZ2xzYjJOaApiR2h2YzNTQ0JXRnNhV05sZ2c1d2IyeGhjaTF1TVMxaGJHbGpaWUlFZFc1cGVJSUtkVzVwZUhCaFkydGxkSUlIClluVm1ZMjl1Ym9jRWZ3QUFBWWNRQUFBQUFBQUFBQUFBQUFBQUFBQUFBWWNFckJnQUJqQUtCZ2dxaGtqT1BRUUQKQWdOSUFEQkZBaUJ2ei9oS29OMEpsdFdnanpCSFlIcEI0Zk0ydHFQZ2U5ajFtMXR0MHllOFBnSWhBSmtHdys1YwpoRXVINWJWRkxCUWpvNVNVQVcvc0dYOWkwYVNxY1NKQkVFUlEKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=',
          macaroon: 'AgEDbG5kAvgBAwoQZfbno2BCpVfn+g6USaC3JRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYg61atst43JqOPEZKGrLszr6q8eWVvQfxgr1inv45ukJ4=',
          lightning: { channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 } }
        )

        expect(client.connection[:lightning]).to eq(
          { channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 } }
        )

        expect(
          VCR.reel.replay('dsl.wallet_balance.total_balance', as: "alice/#{key}") do
            client.lightning.describe_graph.nodes.size
          end
        ).to eq(3)
      end
    end
  end

  describe 'Multiclient' do
    before do
      LNDClientInternal::Multiclient.instance.clear!
    end

    it 'adds and removes connections' do
      described_class.add_connection!(
        'alice',
        'lndconnect://127.0.0.1:10001?cert=MIICJzCCAc2gAwIBAgIRAImZs0ieSBjBcMtpD8oQ_okwCgYIKoZIzj0EAwIwMTEfMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEOMAwGA1UEAxMFYWxpY2UwHhcNMjMwMzEyMjM0NDEyWhcNMjQwNTA2MjM0NDEyWjAxMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MQ4wDAYDVQQDEwVhbGljZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABL8ZHtjXzSy7Qs9SL0wECTsAwyX8xplEox1DQUMnB6mfu5dXxzuTqoyCL1FuwjthqfZNO3hX2O-o5pyHxGkqYA2jgcUwgcIwDgYDVR0PAQH_BAQDAgKkMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA8GA1UdEwEB_wQFMAMBAf8wHQYDVR0OBBYEFFXs5yUhjbRfmlYGGEYPlzquQdslMGsGA1UdEQRkMGKCBWFsaWNlgglsb2NhbGhvc3SCBWFsaWNlgg5wb2xhci1uMS1hbGljZYIEdW5peIIKdW5peHBhY2tldIIHYnVmY29ubocEfwAAAYcQAAAAAAAAAAAAAAAAAAAAAYcErBgABjAKBggqhkjOPQQDAgNIADBFAiBvz_hKoN0JltWgjzBHYHpB4fM2tqPge9j1m1tt0ye8PgIhAJkGw-5chEuH5bVFLBQjo5SUAW_sGX9i0aSqcSJBEERQ&macaroon=AgEDbG5kAvgBAwoQZfbno2BCpVfn-g6USaC3JRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYg61atst43JqOPEZKGrLszr6q8eWVvQfxgr1inv45ukJ4'
      )

      described_class.add_connection!(
        'bob',
        address: '127.0.0.1:10002',
        certificate: '2d2d2d2d2d424547494e2043455254494649434154452d2d2d2d2d0a4d494943486a434341634f674177494241674952414b46497a6743615737416438455a2f544e706e51684177436759494b6f5a497a6a3045417749774c7a45660a4d4230474131554543684d576247356b494746316447396e5a57356c636d46305a575167593256796444454d4d416f474131554541784d44596d39694d4234580a4454497a4d444d784d6a497a4e4451784d566f58445449304d4455774e6a497a4e4451784d566f774c7a45664d4230474131554543684d576247356b494746310a6447396e5a57356c636d46305a575167593256796444454d4d416f474131554541784d44596d39694d466b77457759484b6f5a497a6a3043415159494b6f5a490a7a6a304441516344516741454272776a6748343755356f504a30584632796e33354d4c534a77336474376b52756668346a6d6c6b455469562b35686844512b700a4472536a6b4d55614b38426a3441755a46573568304e5062487153582b4d6a4f4e4b4f42767a43427644414f42674e56485138424166384542414d43417151770a457759445652306c42417777436759494b775942425155484177457744775944565230544151482f42415577417745422f7a416442674e5648513445466751550a66616d362f525a486c596d3358686a303745353357794c63494163775a515944565230524246347758494944596d396967676c7362324e6862476876633353430a41324a76596f494d6347397359584974626a4574596d396967675231626d6c3467677031626d6c346347466a613256306767646964575a6a623235756877522f0a4141414268784141414141414141414141414141414141414141414268775373474141464d416f4743437147534d343942414d4341306b414d4559434951444d0a65776333336a7030536c4d57367862554a4b45504a5255673574644e673741387750725430666f322f6749684150316751467a4e56396666464437492f7934500a7961743439725071544e424674744c6246555362556759770a2d2d2d2d2d454e442043455254494649434154452d2d2d2d2d0a',
        macaroon: '0201036c6e6402f801030a1034f2c1bd2b2bda4335a743353a23d1c61201301a160a0761646472657373120472656164120577726974651a130a04696e666f120472656164120577726974651a170a08696e766f69636573120472656164120577726974651a210a086d616361726f6f6e120867656e6572617465120472656164120577726974651a160a076d657373616765120472656164120577726974651a170a086f6666636861696e120472656164120577726974651a160a076f6e636861696e120472656164120577726974651a140a057065657273120472656164120577726974651a180a067369676e6572120867656e657261746512047265616400000620efdcb8b613efb5a677f3c185ebae02d657d17313f071947b1dd2b3875003c38f',
        lightning: {
          channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 }
        }
      )

      described_class.add_connection!(
        'carol',
        'lndconnect://127.0.0.1:10003?cert=MIICJzCCAc2gAwIBAgIRAKFN89_Svnuw_14x4qNvtQEwCgYIKoZIzj0EAwIwMTEfMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEOMAwGA1UEAxMFY2Fyb2wwHhcNMjMwMzEyMjM0NDExWhcNMjQwNTA2MjM0NDExWjAxMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MQ4wDAYDVQQDEwVjYXJvbDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABMaXKFV0YVbB0t0WI0QR6iyiOW1pgEas40zi3V3VW5XwMgtqd00suOBMk6-gjvZ1vDu16FY12Zsy7JvmTW-eLsKjgcUwgcIwDgYDVR0PAQH_BAQDAgKkMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA8GA1UdEwEB_wQFMAMBAf8wHQYDVR0OBBYEFKwSTXEHYOpKpXuzWnu_8suXM2nZMGsGA1UdEQRkMGKCBWNhcm9sgglsb2NhbGhvc3SCBWNhcm9sgg5wb2xhci1uMS1jYXJvbIIEdW5peIIKdW5peHBhY2tldIIHYnVmY29ubocEfwAAAYcQAAAAAAAAAAAAAAAAAAAAAYcErBgABDAKBggqhkjOPQQDAgNIADBFAiBkpH3F7OsDqe7Q1kKJquhqGFIWYU_VlVO2Agr95idEMAIhAPZtMvBClkr4B7mck5ysT19Cm9DJnoobveSsux-lvN_P&macaroon=AgEDbG5kAvgBAwoQuaWR-AHtm47gtUfwKxEtahIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYgvAgzXe69XM3o9J_2xVJyz8jDY5_wh1uwD-7UTFNX9l8',
        lightning: {
          channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 }
        }
      )

      expect(described_class.as('alice').connection.keys).to eq(
        %i[connect host port certificate macaroon address credentials]
      )

      expect(described_class.as('bob').connection.keys).to eq(
        %i[address certificate macaroon lightning credentials]
      )

      expect(described_class.as('bob').connection[:lightning]).to eq(
        { channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 } }
      )

      expect(described_class.as('carol').connection.keys).to eq(
        %i[connect host port certificate macaroon address lightning credentials]
      )

      expect(described_class.as('carol').connection[:lightning]).to eq(
        { channel_args: { 'grpc.max_receive_message_length' => 1024 * 1024 * 50 } }
      )

      expect(
        VCR.reel.replay('multiclient.wallet_balance.total_balance', as: 'alice') do
          described_class.as('alice').lightning.get_info.alias
        end
      ).to eq('alice')

      expect(
        VCR.reel.replay('multiclient.wallet_balance.total_balance', as: 'bob') do
          described_class.as('bob').lightning.get_info.alias
        end
      ).to eq('bob')

      expect(
        VCR.reel.replay('multiclient.wallet_balance.total_balance', as: 'carol') do
          described_class.as('carol').lightning.get_info.alias
        end
      ).to eq('carol')

      expect(described_class.connections).to eq(%w[alice bob carol])

      described_class.remove_connection!('bob')

      expect(described_class.connections).to eq(%w[alice carol])
    end
  end
end
