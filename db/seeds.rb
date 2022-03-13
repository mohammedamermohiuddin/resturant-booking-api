puts 'Admin user being created'
begin
	first_admin_user = User.new(email:'admin@test.com', employee_no: '0011', role: 'admin', employee_name: 'John Doe', password: ENV['FIRST_ADMIN_PWD'].to_s,password_confirmation: ENV['FIRST_ADMIN_PWD'].to_s)
	if first_admin_user.save
		if first_admin_user.update(added_by: first_admin_user['id'])
			puts 'Admin user created successfully'
		else
			puts 'Admin user created_by updation failed'
		end
	else
		puts 'Admin user creation failed: Please check all mandatory user table fields are populated'
	end
rescue StandardError => e
	puts e.inspect + ' backtrace: ' + e.backtrace.to_s
	puts "Admin user creation failed: #{e.to_s}"
end