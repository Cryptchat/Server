require 'openssl'

message = "HELLO THIS IS TEST"

ec1 = OpenSSL::PKey::EC.generate("prime256v1")
ec2 = OpenSSL::PKey::EC.generate("prime256v1")

shared_key1 = ec1.dh_compute_key(ec2.public_key)
shared_key2 = ec2.dh_compute_key(ec1.public_key)

rsa1 = OpenSSL::PKey::RSA.new 2048
rsa2 = OpenSSL::PKey::RSA.new 2048

signed_message = rsa1.private_encrypt(message)
cipher = OpenSSL::Cipher::AES.new(256, :CBC)
cipher.encrypt
cipher.key = shared_key1
iv = cipher.random_iv
encrypted = cipher.update(message) + cipher.final


decipher = OpenSSL::Cipher::AES.new(256, :CBC)
decipher.decrypt
decipher.key = shared_key2
decipher.iv = iv
plain = decipher.update(encrypted) + decipher.final
# plain = rsa1.public_decrypt(signed)
puts plain

exit
puts ec1.methods.join(", ")
puts "__________"
puts ec1.private_key?
