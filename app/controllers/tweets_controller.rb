require 'net/http'
require 'net/https'
require 'oauth'
require 'json'



class TweetsController < ApplicationController

  def authorize_twitter
    auth = request.env['omniauth.auth']

    if auth
      current_twitter_user = {
          name: auth.info.name,
          email: auth.info.email,
          image: auth.info.image
      }
      session[:current_user] = current_twitter_user
      session[:oauth_token] = params[:oauth_token]
      session[:oauth_secret] = params[:oauth_verifier]
    end

    flash[:notice] = 'authorized successfully'
    redirect_to root_path

  end

  def tweet
    tweet_url = 'https://api.twitter.com/1.1/statuses/update.json?display_coordinates=false '
    status = params[:message]
    body = {status: status}
    method = 'POST'

    p = {'Authorization' => twitter_oauth}
    puts p

    http = HTTPClient.new
    response = http.post(tweet_url, body, {'Authorization' => twitter_oauth})
    p response.inspect
    exit

  end

  private

  def sign(key, base_string)
    digest = OpenSSL::Digest::Digest.new('sha1')
    hmac = OpenSSL::HMAC.digest(digest, key, base_string)
    Base64.encode64(hmac).chomp.gsub(/\n/, '')
  end

  def signature_base_string(method, uri, params)
    # Join up the parameters into one long URL-safe string of key value pairs
    encoded_params = params.sort.collect{ |k, v| url_encode("#{k}=#{v}") }.join('%26')
    # Join the above with your method and URL-safe destination URL
    method + '&' + url_encode(uri) + '&' + encoded_params
  end

  def url_encode(string)
    CGI::escape(string)
  end


  def twitter_oauth

    tweet_url = 'https://api.twitter.com/1.1/statuses/update.json'
    oauth_access_token = '722730710990069760-zD8txoHweMS1nx6SLEKrjyhzRIlVUTV'
    oauth_access_token_secret = 'yRzqh5iUrLTVXsuCBCmYHfm8XtRrc5SoC1xBT4nKujUU4'
    consumer_key = 'xwRQUgB75JWIZDbrZA3MxlavD'
    consumer_secret = 'BBcWHMHBzGtK6tGTfmOjc6umTG3o6y7XOA74fXFq2V1zBfRnyR'

    oauth_data = {
        oauth_consumer_key: consumer_key,
        oauth_nonce: generate_nonce,
        oauth_signature_method: 'HMAC-SHA1',
        oauth_token: oauth_access_token,
        oauth_timestamp: Time.now.to_i,
        oauth_version: '1.0'
    }
    oauth =  build_headers(oauth_data)

    x = {}
    x['abc'] = 'xyz'

    signature_base_string = signature_base_string('POST', tweet_url, x)

    signing_key = consumer_secret + '&' + oauth_access_token
    oauth << "oauth_signature = '#{url_encode(sign(signing_key, signature_base_string))}' "
    oauth << "Host: api.twitter.com "
    oauth << "Content-Length: 0 "
    oauth << "X-Target-URI: https://api.twitter.com "
    oauth << "Connection: Keep-Alive"
    #oauth << "Connection: Keep-Alive"



    oauth
  end

  def build_headers(oauth)
      header = "OAuth "
      oauth.each do |k, v|
        header += "#{k}=\"#{v}\","
      end
      header.slice(0..-3)
      header

=begin
    header_str = "Authorization: OAuth "
    header_str << "oauth_consumer_key= '#{oauth[:oauth_consumer_key]}', "
    header_str << "oauth_nonce = '#{oauth[:oauth_nonce]}', "
    header_str << "oauth_signature_method = '#{oauth[:oauth_signature_method]}', "
    header_str << "oauth_timestamp = '#{oauth[:oauth_timestamp]}', "
    header_str << "oauth_token = '#{oauth[:oauth_token]}', "
    header_str << "oauth_version = '#{oauth[:oauth_version]}' "
    header_str
=end


  end

  def generate_nonce(size=7)
    Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
  end

end
