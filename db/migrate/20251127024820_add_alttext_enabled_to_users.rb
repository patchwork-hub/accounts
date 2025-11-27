class AddAlttextEnabledToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :alttext_enabled, :boolean, null: false, default: false
  end
end
