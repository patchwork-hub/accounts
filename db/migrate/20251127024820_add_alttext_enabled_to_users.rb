class AddAlttextEnabledToUsers < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:users, :alttext_enabled)
      add_column :users, :alttext_enabled, :boolean, null: false, default: false
    end
  end
end
