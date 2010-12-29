require 'uri'
require 'net/http'
require 'net/https'
require 'json'


class Bubo
#  HOSTNAME = 'bubo.heroku.com'
#  PORT = 80
  HOSTNAME = '127.0.0.1'
  PORT = 3000

  def initialize(email, api_key)
    @settings = { :email => email, :api_key => api_key }
  end

  def api_verification
    { :email => @settings[:email], :api_key => @settings[:api_key] }
  end

  def images_status
    JSON.parse( send('images') )
  end

  def add_image(key, url)
    send('images/add', :post, {:key => key, :url => url}) == 'OK'
  end
  
  def remove_image(key)
    send('images/remove', :post, {:key => key}) == 'OK'
  end

  def inspect_image(key)
    send('images/inspect', :get, {:key => key})
  end

  def failed_image_keys
    send('images/failures').split("\n")
  end


private

  def send(path, method = :get, form_data = {})
    form_data = form_data.merge(api_verification)
    form_data = form_data.inject({}) { |m, (k, v)| m[k.to_s] = v; m }

    response = ''
    http = Net::HTTP.new(HOSTNAME, PORT)
    http.start do |http|
      if(method == :get)
        request = Net::HTTP::Get.new('/'+path)
      else
        request = Net::HTTP::Post.new('/'+path)
      end
      request.set_form_data(form_data)
      response = http.request(request)
      response = response.body.strip
    end
    
    response
  end

end