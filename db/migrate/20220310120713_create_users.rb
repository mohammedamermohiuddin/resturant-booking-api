class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :employee_no, null: false
      t.string :employee_name, null: false
      t.string :encrypted_password, null: false
      t.string :email, null: false
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip
      t.integer :added_by
      t.timestamps null: false
    end
    add_index :users, :employee_no, unique: true
    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
