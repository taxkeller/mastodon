require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddColumnToUsersForFacebook < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :users, :uid, :string, default: '', allow_null: false
      add_column_with_default :users, :provider, :string, default: '', allow_null: true
    end
    add_index :users, :uid, unique: true, algorithm: :concurrently
  end

  def down
    remove_index :users, :uid
    remove_column :users, :uid
    remove_column :users, :provider
  end
end
