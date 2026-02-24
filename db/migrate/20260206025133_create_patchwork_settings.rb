class CreatePatchworkSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :patchwork_settings, if_not_exists: true do |t|
      t.integer :app_name, default: 0, null: false
      t.references :account, null: false, foreign_key: { to_table: :accounts, on_delete: :cascade, validate: false }
      t.jsonb :settings, default: {}
      t.timestamps
    end
  end
end
