class AddRoleForUser < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE user_role AS ENUM ('admin', 'employee');      
    SQL
    add_column :users, :role, :user_role, index: true
  end

  def down
    execute <<-SQL
      DROP index users.role_index;
    SQL
    remove_column :users, :role
  end
end
