require "net/http"
require "uri"
require "json"

class FaceRecognitionService
  SERVICE_URL = ENV.fetch("FACE_SERVICE_URL", "http://localhost:8001")

  def self.encode_face(image_base64)
    uri = URI.parse("#{SERVICE_URL}/encode")
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = { image_base64: image_base64 }.to_json

    res = http_request(uri, req)
    JSON.parse(res.body, symbolize_names: true)
  rescue => e
    Rails.logger.error("FaceRecognitionService.encode_face error: #{e.message}")
    { success: false, error: "Service error" }
  end

  def self.authenticate_face(image_base64, known_encodings)
    uri = URI.parse("#{SERVICE_URL}/authenticate")
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = {
      image_base64: image_base64,
      known_encodings: known_encodings
    }.to_json

    res = http_request(uri, req)
    JSON.parse(res.body, symbolize_names: true)
  rescue => e
    Rails.logger.error("FaceRecognitionService.authenticate_face error: #{e.message}")
    { success: false, error: "Service error" }
  end

  private

  def self.http_request(uri, req)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 10) do |http|
      http.request(req)
    end
  end
end
