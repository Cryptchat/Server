require 'openssl'
require 'xor'

# credits to https://github.com/discourse/discourse/blob/master/lib/pbkdf2.rb ^_^
# thanks discourse and Sam!

class Pbkdf2
  class << self
    def hash_secret(secret, salt, iterations, algorithm = "sha256")
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
