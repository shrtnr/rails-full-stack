class CreateShortcodes < ActiveRecord::Migration[5.2]
  def change
    create_table :shortcodes do |t|
      t.string :key
      t.string :url

      t.references :user

      t.timestamps
    end

    add_index :shortcodes, :key, unique: true
    add_foreign_key :shortcodes, :users
  end
end
