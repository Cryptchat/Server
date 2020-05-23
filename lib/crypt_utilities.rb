# frozen_string_literal: true
require 'openssl'
require 'xor'
require 'securerandom'

class CryptUtilities
  class << self
    def generate_digits_token(size)
      num = SecureRandom.rand
      while num == 0
        num = SecureRandom.rand
      end

      while num < 10**(size - 1)
        num = num * 10
      end
      num.floor.to_s
    end

    def salt_and_hash(secret, iterations, algorithm = 'sha256')
      salt = SecureRandom.hex(16)
      hash = pbkdf2_hash(secret, salt, iterations, algorithm)
      [salt, hash]
    end

    def pbkdf2_hash(secret, salt, iterations, algorithm = "sha256")
      # credits to https://github.com/discourse/discourse/blob/master/lib/pbkdf2.rb ^_^
      # thanks discourse and Sam!

      h = OpenSSL::Digest.new(algorithm)
      u = ret = prf(h, secret, salt + [1].pack("N"))

      2.upto(iterations) do
        u = prf(h, secret, u)
        ret.xor!(u)
      end

      ret.bytes.map { |b| ("0" + b.to_s(16))[-2..-1] }.join("")
    end

    private

    def prf(hash_function, secret, data)
      OpenSSL::HMAC.digest(hash_function, secret, data)
    end
  end
end
