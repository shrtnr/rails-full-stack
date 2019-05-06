class CreateShortcodes < ActiveRecord::Migration[5.2]
  def change
    create_table :shortcodes do |t|
      t.string :shortcode
      t.string :url
      t.boolean :allow_params

      t.references :user

      t.timestamps
    end

    add_index :shortcodes, :shortcode, unique: true
    add_foreign_key :shortcodes, :users
  end
end
