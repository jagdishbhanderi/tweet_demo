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
    base_tweet_url = 'https://api.twitter.com/1.1/statuses/update.json?include_entities=true'

    status = params[:message]
    body = {status: status}

    http = HTTPClient.new
    response = http.post(base_tweet_url, body, {
                                           oauth_token: session[:oauth_token],
                                           oauth_nonce: session[:oauth_secret],
                                       })
    p response.inspect
    exit


  end

end
