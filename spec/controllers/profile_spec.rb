# frozen_string_literal: true

require_relative '../../controllers/profile'

RSpec.describe LNDClientInternal::Profile do
  describe '.as' do
    let(:alice_macaroon_admin) do
      path = '/home/icebaker/.polar/networks/1/volumes/lnd/alice/data/chain/bitcoin/regtest/admin.macaroon'
      LNDClientInternal::Connector.instance.load_macaroon(path) do |load|
        VCR.reel.replay('connector.load_macaroon', who: 'alice', role: 'admin') do
          load.call
        end
      end
    end

    let(:alice_certificate) do
      path = '/home/icebaker/.polar/networks/1/volumes/lnd/alice/tls.cert'
      LNDClientInternal::Connector.instance.load_certificate(path) do |load|
        VCR.reel.replay('connector.load_certificate', who: 'alice') do
          load.call
        end
      end
    end

    it 'registers and impersonate' do
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
        'lndconnect://127.0.0.1:10002?cert=MIICHjCCAcOgAwIBAgIRAKFIzgCaW7Ad8EZ_TNpnQhAwCgYIKoZIzj0EAwIwLzEfMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEMMAoGA1UEAxMDYm9iMB4XDTIzMDMxMjIzNDQxMVoXDTI0MDUwNjIzNDQxMVowLzEfMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEMMAoGA1UEAxMDYm9iMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEBrwjgH47U5oPJ0XF2yn35MLSJw3dt7kRufh4jmlkETiV-5hhDQ-pDrSjkMUaK8Bj4AuZFW5h0NPbHqSX-MjONKOBvzCBvDAOBgNVHQ8BAf8EBAMCAqQwEwYDVR0lBAwwCgYIKwYBBQUHAwEwDwYDVR0TAQH_BAUwAwEB_zAdBgNVHQ4EFgQUfam6_RZHlYm3Xhj07E53WyLcIAcwZQYDVR0RBF4wXIIDYm9igglsb2NhbGhvc3SCA2JvYoIMcG9sYXItbjEtYm9iggR1bml4ggp1bml4cGFja2V0ggdidWZjb25uhwR_AAABhxAAAAAAAAAAAAAAAAAAAAABhwSsGAAFMAoGCCqGSM49BAMCA0kAMEYCIQDMewc33jp0SlMW6xbUJKEPJRUg5tdNg7A8wPrT0fo2_gIhAP1gQFzNV9ffFD7I_y4Pyat49rPqTNBFttLbFUSbUgYw&macaroon=AgEDbG5kAvgBAwoQNPLBvSsr2kM1p0M1OiPRxhIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYg79y4thPvtaZ388GF664C1lfRcxPwcZR7HdKzh1ADw48'
      )

      expect(
        VCR.reel.replay('lightning.wallet_balance.total_balance', as: 'alice/path') do
          described_class.instance.as('alice/path').lightning.wallet_balance.total_balance
        end
      ).to eq(483_526)

      expect(
        VCR.reel.replay('lightning.wallet_balance.total_balance', as: 'alice') do
          described_class.instance.as('alice').lightning.wallet_balance.total_balance
        end
      ).to eq(483_526)

      expect(
        VCR.reel.replay('lightning.wallet_balance.total_balance', as: 'bob') do
          described_class.instance.as('bob').lightning.wallet_balance.total_balance
        end
      ).to eq(0)
    end
  end
end
