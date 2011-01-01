require 'uri'
require 'net/http'
require 'net/https'
require 'json'


class Bubo
  # Create a new Bubo API object.
  #
  # You can freely generate API keys on http://api.askbubo.com/users/new
  #
  # If you have any questions, mail {Hajo Nils Krabbenhoeft}[mailto:hajo@spratpix.com].
  def initialize(email, api_key, host='api.askbubo.com', port=80)
    @settings = { :email => email, :api_key => api_key, :host => host, :port => port }
  end

  # Returns the email and api_key you specified when generating this object.
  def api_verification
    { :email => @settings[:email], :api_key => @settings[:api_key] }
  end

  # Returns the hostname of the currently used Bubo API provider.
  def host
    @settings[:host]
  end

  # Returns the port number of the currently used Bubo API provider.
  def port
    @settings[:port]
  end

  # Retrieve current system status.
  # Return value will look like: 
  #
  # {"FAIL"=>0, "OK"=>13, "TODO"=>0, "UPDATE"=>"IDLE"}
  def images_status
    JSON.parse( send('images') )
  end

  # Add a new image to your searchable collection.
  # Returns true or false
  def add_image(key, url)
    send('images/add', :post, {:key => key, :url => url}) == 'OK'
  end
  
  # Remove an image from your searchable collection.
  # Returns true or false
  def remove_image(key)
    send('images/remove', :post, {:key => key}) == 'OK'
  end

  # Get the analysis status of an image in your collection.
  # Returns either:
  #
  # "OK\t<NUMBER>" where <NUMBER> is the number of feature points used for searching
  #
  # or
  #
  # "FAIL\t<ERROR MESSAGE>"
  def inspect_image(key)
    send('images/inspect', :get, {:key => key})
  end

  # Retrieve an array of keys of images, which failed to import.
  # Returns something like:
  #
  # ["keyA", "anotherKey", "keyC"]
  def failed_image_keys
    send('images/failures').split("\n")
  end

  # Download the url given and search for matching images using an optical near-duplicate search algorithm.
  # Returns an array of strings. Each member is either a comment line starting with # or a search result.
  # Search result lines are formatted as:
  #
  # "<KEY>\t<SCORE>\t<MATRIX>"
  #
  # KEY is the key you specified when adding the image
  # SCORE is a confidence score from 0 to 1 with anything above 0.9 considered excellent
  # MATRIX is a 2x3 affine transformation matrix which can be used to transform the image specified by KEY as to cover the search image.
  def retrieve(url)
    send('images/retrieve', :post, {:url => url}).split("\n")
  end

private

  def send(path, method = :get, form_data = {})
    form_data = form_data.merge(api_verification)
    form_data = form_data.inject({}) { |m, (k, v)| m[k.to_s] = v; m }

    response = ''
    http = Net::HTTP.new(host, port)
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