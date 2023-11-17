module RequestMocks
  VALID_CERT = <<~CERT
  -----BEGIN CERTIFICATE-----
  MIIF/TCCA+WgAwIBAgIUVkGvj1cTGx1Qvg3DNI7Ffy+HA8cwDQYJKoZIhvcNAQEL
  BQAwgY0xCzAJBgNVBAYTAklFMREwDwYDVQQIDAhMZWluc3RlcjEPMA0GA1UEBwwG
  RHVibGluMRIwEAYDVQQKDAlFdmVydmF1bHQxHDAaBgNVBAMME3JlbGF5LmV2ZXJ2
  YXVsdC5jb20xKDAmBgkqhkiG9w0BCQEWGWVuZ2luZWVyaW5nQGV2ZXJ2YXVsdC5j
  b20wHhcNMjIwMjE4MTUzNzQ2WhcNMzIwMjE2MTUzNzQ2WjCBjTELMAkGA1UEBhMC
  SUUxETAPBgNVBAgMCExlaW5zdGVyMQ8wDQYDVQQHDAZEdWJsaW4xEjAQBgNVBAoM
  CUV2ZXJ2YXVsdDEcMBoGA1UEAwwTcmVsYXkuZXZlcnZhdWx0LmNvbTEoMCYGCSqG
  SIb3DQEJARYZZW5naW5lZXJpbmdAZXZlcnZhdWx0LmNvbTCCAiIwDQYJKoZIhvcN
  AQEBBQADggIPADCCAgoCggIBALdxSWUs2Rw5C3o/sqyZHX4bdrdpGd/jI8D5mU+F
  6pPAJTT1KFo9pL0V7Qf2fPocOUkwGje1nctmkiZ0oMDLaxQabQXuFx1mDpa4lr2O
  dpnDVXzh9d06Lin87vrp+SDyVxudr3/jP2Yw3PBcxPfDdIEsvA8deXAAZHAXgmuR
  DKcYXh8lPXrH0wd2M2UQK+8xprU3qLNlu30GbaEx0CCHcRSkxtpkAHmveiVxnof5
  pn7IIlbklr/X7vEgpm+d8VIB0/oJMKqkWVWCWDlATIcZXtcN0KTuEpiMj0QMlo4i
  xw8w8BIURDn84ApWljbcrqJ9ffn8B/JgFptsoWUjg2W5nfIxVujbVkvBPQ7cgu1a
  hV/JQtWcR/jGm1Qse1m8HxlK0bnQowOrtkJE/JL6Gax6ujyAm7mhAVCRSWIv/SnK
  d4w6uTAil8EAGiID23r822OG59wjiKiZVIXGVoQFzzHqJ+nYkLVBu6h+cs+V8DnL
  DYBkpj+8lBJwTrh+nMG1OeX6Jok0007x7PZUmA7bYjBFsU0HGpsmRin4Iu3Ufz0Z
  ANXn+SlxQ1ZjIeyB/bRYHCnrtPPCAJBBRDLX32uwVVUSlj+66DyGca5okGgnTv0V
  UxSEP9lvClL9wohTtehLejAHXEhI+2ZO07tfCB9wh8CN56WAYtgjSSyP1XRPA9Mw
  jYORAgMBAAGjUzBRMB0GA1UdDgQWBBRCZd5nf33sL/8r7DKmxq1H88T2bDAfBgNV
  HSMEGDAWgBRCZd5nf33sL/8r7DKmxq1H88T2bDAPBgNVHRMBAf8EBTADAQH/MA0G
  CSqGSIb3DQEBCwUAA4ICAQAXNMhOMws4yv7NTxjr1UAchMIqX0EzyR/pWy2DmToj
  NPriE+vSg6ER83cZuaNxrG9xVhICjQ2mcaxK/G8CH3WiIFGCvBy7RoPberTOIVWU
  0C051mo9M0VY0ktimErnNrzjvQLfDHQZixWjvPGwut2toZCxujJ4x0CI3CaejrVU
  sapRsxL5E/Qh3CKBEtfupxBb6+2T/eS/4aSCPst2kuT91prFStamSYL0CWpQ7G7Q
  A8FbnrwO3NrMTB6IshQg9LjK4Z+hB+YBKzVMzm5jwMo2JfXmQbE5dh4fXfPsaCxp
  X2zfsxQCzn1bfDzh64o7UVDk7LCUp0758muPPdBMfV54KuH6/JIwEADK6okA3+lK
  dHcaoAYTfN8ysroDrjmvD0f0MB2OaKnQL2l5QQXxKmtIeLMMEcn8lR81k3XsBlxM
  VWAmR50CrHX0g3z/KfV1aVyxfmcW1nw9MNWP3+2Pvp2flLHZ+b9eSWZd500Sh7Od
  cRHNPrXUABtK/dbNKHUiQV2Ql1yej99cCLoqD+GT5euEe0alwtYr1YRMxP47zh/Z
  Ch3hgrnbD4OG9ssz4ij8b+qxdfMTng/33OsMILyYmXi8NRFoJiAMlpYlltPub8Xu
  Gu2q1tR9TzpXYZ+Yv1/YUApnryI8Dbd2azpYW4obHvGOFS1bxNQ3waqmx51ig45S
  6w==
  -----END CERTIFICATE-----
  CERT

  def mock_valid_cert
    stub_request(:get, "https://ca.evervault.com/").with(
      headers: {
        "Accept"=>"application/json",
        "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Acceptencoding"=>"gzip, deflate",
        "Api-Key"=>"testing",
        "Content-Type"=>"application/json",
        "User-Agent"=>"evervault-ruby/#{Evervault::VERSION}"
      }
    ).to_return({ status: 200, body: VALID_CERT })
  end

  PUBLIC_KEY = "Ax1NYOSqswFgsRoLFTac7eOvRu7h3GuLmUPKlHpOqsFA"

  def mock_cages_keys
    stub_request(:get, "https://api.evervault.com/cages/key").to_return_json(body: { "ecdhKey": PUBLIC_KEY, "ecdhP256Key": PUBLIC_KEY })
  end
end
