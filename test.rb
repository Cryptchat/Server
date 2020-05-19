require 'net/http'
require 'json'

uri = URI("https://fcm.googleapis.com/fcm/send")
req = Net::HTTP::Post.new(uri)
headers = {
  "Content-Type" => "application/json",
  "Authorization" => "key=#{ENV["API_KEY"]}"
}
# req["Content-Type"] = "application/json"
# req["Authorization"] = "key=#{ENV["API_KEY"]}"
# req.set_form_data(JSON.parse(File.read("payload.json")))

res = Net::HTTP.post(uri, File.read("payload.json"), headers)

puts res.inspect
