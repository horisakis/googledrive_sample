class SessionsController < ApplicationController
  def create
    user = User.find_or_create_from_auth(request.env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    client = OAuth2::Client.new(
    ENV['GOOGLE_CLIENT_ID'],
    ENV['GOOGLE_CLIENT_SECRET'],
    { site: 'https://console.developers.google.com',
      authorize_url: '/o/oauth2/auth',
      token_url: '/o/oauth2/token'
    })

    token = OAuth2::AccessToken.new(
      client,
      current_user.go_token
    )

    begin
      token.get('https://accounts.google.com/o/oauth2/revoke', params: { token: token.token })

    rescue OAuth2::Error => e
      if e.message.include?('invalid_token')
        p e.message
      else
        raise
      end
    end

    reset_session
    redirect_to root_path
  end
end
