class User < ApplicationRecord
  def self.find_or_create_from_auth(auth)
    provider = auth[:provider]
    uid = auth[:uid]
    nickname = auth[:info][:nickname]
    image_url = auth[:info][:image]
    token = auth[:credentials][:token]
    refresh = auth[:credentials][:refresh_token]

    user = find_or_create_by(provider: provider, uid: uid) do |u|
      u.nickname = nickname
      u.image_url = image_url
      u.go_token = token
      u.go_token_refresh = refresh
    end

    if user.go_token_refresh.present?
      if user.go_token != token
        user.update(go_token: token)
      end
    else
      if user.go_token != token || user.go_token_refresh != refresh
        user.update(go_token: token, go_token_refresh: refresh)
      end
    end

    user
  end
end
