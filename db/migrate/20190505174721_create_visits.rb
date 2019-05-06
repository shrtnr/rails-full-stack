class CreateVisits < ActiveRecord::Migration[5.2]
  def change
    create_table :visits do |t|
      t.string :remote_ip
      t.string :request
      t.string :referrer
      t.string :user_agent

      t.references :shortcode

      t.timestamps
    end

    add_foreign_key :visits, :shortcodes
  end
end
