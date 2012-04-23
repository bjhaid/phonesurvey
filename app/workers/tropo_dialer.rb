require 'faraday'

class TropoDialer
  @queue = :tropo_dialer

  @tropo_voice_token = ENV['TROPO_VOICE_TOKEN']

  @conn = Faraday.new(:url => "https://api.tropo.com") do |builder|
    builder.use Faraday::Request::JSON
    builder.adapter Faraday.default_adapter
  end

  def self.perform(product_id, number_to_dial)
    product = Product.find(product_id)

    response = @conn.get do |req|
      req.url '/1.0/sessions'
      req.headers['accept'] = 'application/json'
      req.headers['content-type'] = 'application/json'

      req.params['action'] = 'create'
      req.params['token'] = @tropo_voice_token

      req.params['number_to_dial'] = "+1#{number_to_dial}"
      req.params['caller_id'] = product.tropo_number.gsub('+', '')
      req.params['product_id'] = product.id
    end
  end

end
