# frozen_string_literal: true

require_relative '../../components/connector'

RSpec.describe LNDClientInternal::Connector do
  describe '.expand' do
    it 'expands' do
      expect(described_class.expand(
        'lndconnect://127.0.0.1:10001?cert=MIICJzCCAc2gAwIBAgIRAImZs0ieSBjBcMtpD8oQ_okwCgYIKoZIzj0EAwIwMTEfMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEOMAwGA1UEAxMFYWxpY2UwHhcNMjMwMzEyMjM0NDEyWhcNMjQwNTA2MjM0NDEyWjAxMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MQ4wDAYDVQQDEwVhbGljZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABL8ZHtjXzSy7Qs9SL0wECTsAwyX8xplEox1DQUMnB6mfu5dXxzuTqoyCL1FuwjthqfZNO3hX2O-o5pyHxGkqYA2jgcUwgcIwDgYDVR0PAQH_BAQDAgKkMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA8GA1UdEwEB_wQFMAMBAf8wHQYDVR0OBBYEFFXs5yUhjbRfmlYGGEYPlzquQdslMGsGA1UdEQRkMGKCBWFsaWNlgglsb2NhbGhvc3SCBWFsaWNlgg5wb2xhci1uMS1hbGljZYIEdW5peIIKdW5peHBhY2tldIIHYnVmY29ubocEfwAAAYcQAAAAAAAAAAAAAAAAAAAAAYcErBgABjAKBggqhkjOPQQDAgNIADBFAiBvz_hKoN0JltWgjzBHYHpB4fM2tqPge9j1m1tt0ye8PgIhAJkGw-5chEuH5bVFLBQjo5SUAW_sGX9i0aSqcSJBEERQ&macaroon=AgEDbG5kAvgBAwoQZfbno2BCpVfn-g6USaC3JRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYg61atst43JqOPEZKGrLszr6q8eWVvQfxgr1inv45ukJ4'
      ).keys.sort).to eq(%i[certificate host macaroon port])
    end
  end

  describe '.register' do
    let(:alice_macaroon_admin) do
      path = '/home/icebaker/.polar/networks/1/volumes/lnd/alice/data/chain/bitcoin/regtest/admin.macaroon'
      described_class.instance.load_macaroon(path) do |load|
        VCR.reel.replay('connector.load_macaroon', who: 'alice', role: 'admin') do
          load.call
        end
      end
    end

    let(:alice_macaroon_readonly) do
      path = '/home/icebaker/.polar/networks/1/volumes/lnd/alice/data/chain/bitcoin/regtest/readonly.macaroon'
      described_class.instance.load_macaroon(path) do |load|
        VCR.reel.replay('connector.load_macaroon', who: 'alice', role: 'readonly') do
          load.call
        end
      end
    end

    let(:alice_certificate) do
      path = '/home/icebaker/.polar/networks/1/volumes/lnd/alice/tls.cert'
      described_class.instance.load_certificate(path) do |load|
        VCR.reel.replay('connector.load_certificate', who: 'alice') do
          load.call
        end
      end
    end

    it 'manages connections' do
      expect(alice_certificate).to match(/BEGIN CERTIFICATE/)
      expect(alice_certificate).to match(/END CERTIFICATE/)
      expect(alice_macaroon_admin.size).to be > 100
      expect(alice_macaroon_readonly.size).to be > 100

      described_class.instance.register(
        'alice/path', {
          host: '127.0.0.1',
          port: 10_001,
          certificate: alice_certificate,
          macaroon: alice_macaroon_admin
        }
      )

      described_class.instance.register(
        'alice',
        'lndconnect://127.0.0.1:10001?cert=MIICJzCCAc2gAwIBAgIRAImZs0ieSBjBcMtpD8oQ_okwCgYIKoZIzj0EAwIwMTEfMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEOMAwGA1UEAxMFYWxpY2UwHhcNMjMwMzEyMjM0NDEyWhcNMjQwNTA2MjM0NDEyWjAxMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MQ4wDAYDVQQDEwVhbGljZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABL8ZHtjXzSy7Qs9SL0wECTsAwyX8xplEox1DQUMnB6mfu5dXxzuTqoyCL1FuwjthqfZNO3hX2O-o5pyHxGkqYA2jgcUwgcIwDgYDVR0PAQH_BAQDAgKkMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA8GA1UdEwEB_wQFMAMBAf8wHQYDVR0OBBYEFFXs5yUhjbRfmlYGGEYPlzquQdslMGsGA1UdEQRkMGKCBWFsaWNlgglsb2NhbGhvc3SCBWFsaWNlgg5wb2xhci1uMS1hbGljZYIEdW5peIIKdW5peHBhY2tldIIHYnVmY29ubocEfwAAAYcQAAAAAAAAAAAAAAAAAAAAAYcErBgABjAKBggqhkjOPQQDAgNIADBFAiBvz_hKoN0JltWgjzBHYHpB4fM2tqPge9j1m1tt0ye8PgIhAJkGw-5chEuH5bVFLBQjo5SUAW_sGX9i0aSqcSJBEERQ&macaroon=AgEDbG5kAvgBAwoQZfbno2BCpVfn-g6USaC3JRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYg61atst43JqOPEZKGrLszr6q8eWVvQfxgr1inv45ukJ4'
      )

      described_class.instance.register(
        'bob',
        'lndconnect://127.0.0.1:10001?cert=MIICJzCCAc2gAwIBAgIRAImZs0ieSBjBcMtpD8oQ_okwCgYIKoZIzj0EAwIwMTEfMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEOMAwGA1UEAxMFYWxpY2UwHhcNMjMwMzEyMjM0NDEyWhcNMjQwNTA2MjM0NDEyWjAxMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MQ4wDAYDVQQDEwVhbGljZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABL8ZHtjXzSy7Qs9SL0wECTsAwyX8xplEox1DQUMnB6mfu5dXxzuTqoyCL1FuwjthqfZNO3hX2O-o5pyHxGkqYA2jgcUwgcIwDgYDVR0PAQH_BAQDAgKkMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA8GA1UdEwEB_wQFMAMBAf8wHQYDVR0OBBYEFFXs5yUhjbRfmlYGGEYPlzquQdslMGsGA1UdEQRkMGKCBWFsaWNlgglsb2NhbGhvc3SCBWFsaWNlgg5wb2xhci1uMS1hbGljZYIEdW5peIIKdW5peHBhY2tldIIHYnVmY29ubocEfwAAAYcQAAAAAAAAAAAAAAAAAAAAAYcErBgABjAKBggqhkjOPQQDAgNIADBFAiBvz_hKoN0JltWgjzBHYHpB4fM2tqPge9j1m1tt0ye8PgIhAJkGw-5chEuH5bVFLBQjo5SUAW_sGX9i0aSqcSJBEERQ&macaroon=AgEDbG5kAlgDChBj9uejYEKlV-f6DpRJoLclEgEwGhYKB2FkZHJlc3MSBHJlYWQSBXdyaXRlGhcKCGludm9pY2VzEgRyZWFkEgV3cml0ZRoPCgdvbmNoYWluEgRyZWFkAAAGIO7lGQnHDhoCfjhxJMqOd1ekTc2z42mo5rY13x4HzdIn'
      )

      expect(described_class.instance.for('alice/path').keys.sort).to eq(
        [:address, :certificate, :credentials, :host, :macaroon, :port]
      )

      expect(
        described_class.instance.for('alice/path')[:macaroon]
      ).to eq(alice_macaroon_admin)

      expect(
        described_class.instance.for('alice/path')[:certificate]
      ).to eq(alice_certificate)

      expect(
        described_class.instance.for('alice')[:macaroon]
      ).to eq(alice_macaroon_admin)

      expect(
        described_class.instance.for('alice')[:certificate]
      ).to eq(alice_certificate)

      expect(
        described_class.instance.for('bob')[:macaroon]
      ).to eq('0201036c6e640258030a1063f6e7a36042a557e7fa0e9449a0b7251201301a160a0761646472657373120472656164120577726974651a170a08696e766f69636573120472656164120577726974651a0f0a076f6e636861696e12047265616400000620eee51909c70e1a027e387124ca8e7757a44dcdb3e369a8e6b635df1e07cdd227')
    end
  end
end
