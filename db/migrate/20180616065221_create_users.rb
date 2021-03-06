class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :nickname
      t.string :image_url
      t.string :go_token
      t.string :go_token_secret

      t.timestamps
    end
  end
end
