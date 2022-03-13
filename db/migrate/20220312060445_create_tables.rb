class CreateTables < ActiveRecord::Migration[6.1]
  def change
    create_table :tables do |t|
      t.integer :table_number, null: false
      t.integer :number_of_seats, null: false
      t.references :added_by, foreign_key: { to_table: 'users' }
      t.boolean :is_deleted, null: false, default: 0
      t.timestamp :deleted_at
      t.timestamps null: false
      t.references :deleted_by, foreign_key: { to_table: 'users' }
    end
  end
end
