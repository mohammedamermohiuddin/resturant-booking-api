class CreateReservations < ActiveRecord::Migration[6.1]
  def change
    create_table :reservations do |t|
      t.integer :no_of_customers, null: false
      t.timestamp :start_at, null: false
      t.timestamp :end_at, null: false
      t.references :table, foreign_key: true, null: false
      t.references :added_by, foreign_key: { to_table: 'users' }
      t.boolean :is_deleted, null: false, default: 0
      t.timestamp :deleted_at
      t.references :deleted_by, foreign_key: { to_table: 'users' }
      t.string :main_customer_name, null: false
      t.string :main_customer_phone, null: false
      t.timestamps null: false
    end
  end
end
