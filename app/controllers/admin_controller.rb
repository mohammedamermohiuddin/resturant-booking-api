class AdminController < ApplicationController
	before_action :authenticate_request!
	before_action :check_access

	def add_employee
		begin
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00141']), status: 400 if (!(check_nil_and_empty(params[:employeeNumber])) || !(check_nil_and_empty(params[:employeeName])) || !(check_nil_and_empty(params[:employeeRole])) || !(check_nil_and_empty(params[:password])))
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00144']), status: 400 if params[:employeeNumber].to_s.match(/^[0-9]{4}$/).nil?
			emp_no_used = User.find_by(employee_no: params[:employeeNumber].to_s)
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00145']), status: 400 if !emp_no_used.nil?
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00146']), status: 400 if params[:password].to_s.match(PASSWORD_FORMAT).nil?
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00150']), status: 400 if params[:employeeRole].to_s.downcase != 'admin' && params[:employeeRole].to_s.downcase != 'employee'
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00148']), status: 400 if !params[:employeeName].to_s.scan(SPECIAL_CHARACTERS).empty?
			new_user = User.new(email:"user_#{params[:employeeNumber].to_s}@test.com", employee_no: params[:employeeNumber].to_s, role: params[:employeeRole].to_s.downcase, employee_name: params[:employeeName].to_s.strip.split(" ").map(&:capitalize)*' ', password: params[:password].to_s,password_confirmation: params[:password].to_s)
			if new_user.save
				return render json: {
					data: {
						employeeName: new_user.employee_name,
						employeeNumber: new_user.employee_no,
						employeeRole: new_user.role.capitalize,
						employeeRegistrationId: new_user.id,
						employeeRegisteredAt: new_user.created_at
					},
				}.merge(ApiStatusCodesHelper.setup('I00001', ['U00200'])), status: 200
			else
				return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
			end
		rescue Exception => apiCallExcep
	    	puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
	    	return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
	    ensure
	    	emp_no_used, new_user = nil
	    end
	end

	def list_all_tables
		begin
			(params[:page].to_i <= 1) ? params[:page] = 1 : params[:page] = params[:page].to_i
			(params[:sort].to_s != 'ascending') ? params[:sort] = 'descending' : params[:sort] = 'oldest'
			tables_count = Table.where(is_deleted: 0).select('id').all.count
			if params[:sort].to_s == 'descending'
				all_tables = Table.where(is_deleted: 0).select('table_number as tableNumber, number_of_seats as numberOfSeats, id as tableRegistrationId, created_at as tableRegisteredAt').limit(10).offset((params[:page]-1)*10).order(created_at: :desc).as_json(:except => :id)
			else
				all_tables = Table.where(is_deleted: 0).select('table_number as tableNumber, number_of_seats as numberOfSeats, id as tableRegistrationId, created_at as tableRegisteredAt').limit(10).offset((params[:page]-1)*10).order(created_at: :asc).as_json(:except => :id)
			end
			(all_tables.empty?) ? ret_status_code = 'T00404' : ret_status_code = 'T00200'
			return render json: {
				data: {
					totalItems: tables_count,
					page: params[:page],
					itemsPerPage: 10,
					items: all_tables,
				}
			}.merge(ApiStatusCodesHelper.setup('I00001', [ret_status_code,'I00100'])), status: 200
		rescue Exception => apiCallExcep
	    	puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
	    	return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
	    ensure
	    	all_tables = nil
	    end
	end

	def add_table
		begin
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00141']), status: 400 if !check_nil_and_empty(params[:tableNumber]) || !check_nil_and_empty(params[:numberOfSeats])
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00201']), status: 400 if !params[:tableNumber].to_s.scan(/\D/).empty? || params[:tableNumber].to_s.starts_with?("0")
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00202']), status: 400 if params[:numberOfSeats].to_s.match(/^[0-9]{1,2}$/).nil? || params[:numberOfSeats].to_s.length > 2 || params[:numberOfSeats].to_i < 1 || params[:numberOfSeats].to_i > 12
			table_no_used = Table.find_by(table_number: params[:tableNumber].to_i, is_deleted: 0)
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00203']), status: 400 if !table_no_used.nil?
			new_table = Table.new(table_number: params[:tableNumber].to_i, number_of_seats: params[:numberOfSeats].to_i, added_by_id: @global_resturant_user['id'])
			if new_table.save
				return render json: {
					data: {
						tableNumber: new_table.table_number,
						numberOfSeats: new_table.number_of_seats,
						tableRegistrationId: new_table.id,
						tableRegisteredAt: new_table.created_at
					},
				}.merge(ApiStatusCodesHelper.setup('I00001', ['T00200'])), status: 200
			else
				return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
			end
		rescue Exception => apiCallExcep
	    	puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
	    	return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
	    ensure
	    	table_no_used, new_table = nil
	    end
	end

	def delete_table
		begin
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00141']), status: 400 if !check_nil_and_empty(params[:tableNumber])
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00201']), status: 400 if !params[:tableNumber].to_s.scan(/\D/).empty? || params[:tableNumber].to_s.starts_with?("0")
			table_found = Table.find_by(table_number: params[:tableNumber].to_i, is_deleted: 0)
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00010']), status: 400 unless !table_found.nil?
			reservation_found = Reservation.find_by(table_id: table_found.id)
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00205']), status: 400 unless reservation_found.nil?
			if table_found.update(is_deleted: 1, deleted_by_id: @global_resturant_user['id'],deleted_at: Time.now)
				return render json: {
					data: {
						tableNumber: table_found.table_number,
						tableRegistrationId: table_found.id,
						tableRegisteredAt: table_found.created_at,
						tableRemovedAt: table_found.deleted_at
					},
				}.merge(ApiStatusCodesHelper.setup('I00001', ['T00210'])), status: 200
			else
				return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
			end
		rescue Exception => apiCallExcep
	    	puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
	    	return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
	    ensure
	    	table_found = nil
	    end
	end

	def list_all_reservations
		begin
			(params[:page].to_i <= 1) ? params[:page] = 1 : params[:page] = params[:page].to_i
			(params[:sort].to_s != 'ascending') ? params[:sort] = 'descending' : params[:sort] = 'oldest'
			begin
				selected_date = Date.strptime(params[:date].to_s, '%Y-%m-%d')
				selected_date_query = "and DATE(res.start_at) = '#{clean_var_for_sql(selected_date.to_s).to_s}' and DATE(res.end_at) = '#{clean_var_for_sql(selected_date.to_s).to_s}'"
			rescue Exception => dateParseError
				selected_date_query = ''
			end
			if check_nil_and_empty(params[:tableNumbers])
				selected_table_numbers_query = "and tab.table_number in (#{clean_var_for_sql(params[:tableNumbers].to_s).to_s})"
			else
				selected_table_numbers_query = ''
			end
			reservations_count = Reservation.where("is_deleted = ? #{selected_date_query.gsub('res.','')}", 'false').select('id').all.count
			if params[:sort].to_s == 'descending'
				sort_as = 'desc'
			else
				sort_as = 'asc'
			end
			begin
				all_reservations = ActiveRecord::Base.connection.exec_query("select tab.table_number tableNumber, res.main_customer_name as reservingCustomerName, res.main_customer_phone as reservingCustomerPhone, res.start_at as reservationStartAt, res.end_at as reservationEndAt, res.id as reservationRegistrationId,res.created_at as reservationRegisteredAt from reservations res, tables tab where tab.id = res.table_id and res.is_deleted = false #{selected_date_query} #{selected_table_numbers_query} order by res.created_at #{sort_as.to_s} limit 10 offset #{((clean_var_for_sql(params[:page]-1)).to_i*10).to_s}").as_json
			rescue Exception => apiCallExcep
				puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
				return render json: ApiStatusCodesHelper.setup('E00001', ['E00101']), status: 500
			end
			(all_reservations.empty?) ? ret_status_code = 'R00404' : ret_status_code = 'R00200'
			return render json: {
				data: {
					totalItems: reservations_count,
					page: params[:page],
					itemsPerPage: 10,
					items: all_reservations
				}
			}.merge(ApiStatusCodesHelper.setup('I00001', [ret_status_code,'I00100'])), status: 200
		rescue Exception => apiCallExcep
	    	puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
	    	return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
	    ensure
	    	all_reservations, selected_date, selected_date_query = nil
	    end
	end
end
