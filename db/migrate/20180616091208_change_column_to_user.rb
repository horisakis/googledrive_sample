class ChangeColumnToUser < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :go_token_secret, :go_token_refresh
  end
end
