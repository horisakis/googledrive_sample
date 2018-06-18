class StaticPagesController < ApplicationController
  def index
    if current_user

      credentials = Google::Auth::UserRefreshCredentials.new(
        client_id: ENV['GOOGLE_CLIENT_ID'],
        client_secret: ENV['GOOGLE_CLIENT_SECRET'],
        scope: [
          'https://www.googleapis.com/auth/drive',
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile'
        ],
        additional_parameters: { 'access_type' => 'offline' }
      )
      # credentials.access_token = current_user.go_token

      ## アクセストークンが期限切れの場合等にはrefreshトークンだけ設定してfetchする事で
      ## インスタンスに保持しているアクセストークンを消去する模様？
      credentials.refresh_token = current_user.go_token_refresh
      begin
        credentials.fetch_access_token!
        session = GoogleDrive::Session.from_credentials(credentials)
        # session = GoogleDrive::Session.from_access_token(current_user.go_token)

        binding.pry
        # unless session.folders_by_name('api-test')
        #   session.create_folder('api-test')
        #
        # end

        folder_path = "api-test/api-test2/api-test3"
        folder = find_or_create_folder(session.root_folder,
                                       folder_path.split('/'))
        folder.upload_from_io(open('https://pbs.twimg.com/media/DfnxVtLVQAAXUkV.jpg'))
      rescue Signet::AuthorizationError

      end

      #   @client = Twitter::REST::Client.new do |config|
      #     config.consumer_key        = ENV['GOOGLE_CLIENT_ID']
      #     config.consumer_secret     = ENV['GOOGLE_CLIENT_SECRET']
      #     config.access_token        = @current_user.go_token
      #     config.access_token_secret = @current_user.go_token_secret
      #   end
    end
  end


  def find_or_create_folder(collection, folder_names)
    folder_name = folder_names.shift
    return collection if folder_name.blank?
binding.pry
    # subcollection = collection.subcollection_by_title(folder_name)
    subcollections = collection.files(q: "name='#{folder_name}' and trashed = false")
    if subcollections.nil?
      subcollection = collection.create_subcollection(folder_name)
      folder_names.present? ? create_folder(subcollection, folder_names) : subcollection
    else
      # find_or_create_folder(subcollection, folder_names) if folder_names.present?
      folder_names.present? ? find_or_create_folder(subcollections[0], folder_names) : subcollections[0]
    end
  end

  def create_folder(collection, folder_names)
    folder_name = folder_names.shift
    return collection if folder_name.blank?

    # subcollection = collection.create_subcollection(folder_name)
    subcollection = collection.files(q: "name = ${folder_name} and trashed = false")
    folder_names.present? ? create_folder(subcollection, folder_names) : subcollection
  end
end
