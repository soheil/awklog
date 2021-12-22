class ChangeUserIdToApiKeyInLogs < ActiveRecord::Migration[6.0]
  def change
    rename_column :logs, :user_id, :api_key
  end
end
