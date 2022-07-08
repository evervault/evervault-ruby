require_relative "base"

# https://neuromancer.sk/std/x962/prime256v1

module P256_CONSTANTS
  A = "FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC"
  B = "5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B"
  SEED = "C49D360886E704936A6678E1139D26B7819F7E90"
  P = "FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF"
  GENERATOR = "046B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C2964FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5"
  N = "FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551"
  H = "01"
end

module Evervault
  module Crypto
    module Curves
      class P256 < CurveBase
        def initialize()
          super(curve_name: 'prime256v1', curve_values: P256_CONSTANTS)
        end
      end
    end
  end
end