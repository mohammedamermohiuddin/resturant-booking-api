class ReservationController < ApplicationController
	before_action :authenticate_request!
	before_action :check_access

	def add_reservation
		begin
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00141']), status: 400 if !check_nil_and_empty(params[:tableNumber]) || !check_nil_and_empty(params[:reservationStartAt]) || !check_nil_and_empty(params[:reservationEndAt]) || !check_nil_and_empty(params[:numberOfCustomers]) || !check_nil_and_empty(params[:reservingCustomerName]) || !check_nil_and_empty(params[:reservingCustomerPhone])
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00148']), status: 400 if !params[:reservingCustomerName].to_s.scan(SPECIAL_CHARACTERS).empty?
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00149']), status: 400 if validate_phone(params[:reservingCustomerPhone]) == false
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00201']), status: 400 if !params[:tableNumber].to_s.scan(/\D/).empty? || params[:tableNumber].to_s.starts_with?("0")
			table_found = Table.find_by(table_number: params[:tableNumber].to_i, is_deleted: 0)
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00010','AE00204']), status: 400 unless !table_found.nil?
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00210']), status: 400 if params[:numberOfCustomers].to_i > table_found.number_of_seats
			begin
				bk_start_datetime = DateTime.strptime(params[:reservationStartAt].to_s, '%Y-%m-%d %H:%M')
				bk_start_date = bk_start_datetime.to_date
				bk_start_hour = bk_start_datetime.hour
				bk_start_minute = bk_start_datetime.minute
			rescue Exception => dateParseError
				return render json: ApiStatusCodesHelper.setup('E00001', ['AE00211','AE00213']), status: 400
			end
			begin
				bk_end_datetime = DateTime.strptime(params[:reservationEndAt].to_s, '%Y-%m-%d %H:%M')
				bk_end_date = bk_end_datetime.to_date
				bk_end_hour = bk_end_datetime.hour
				bk_end_minute = bk_end_datetime.minute
			rescue Exception => dateParseError
				return render json: ApiStatusCodesHelper.setup('E00001', ['AE00212','AE00213']), status: 400
			end
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00220']), status: 400 if (bk_start_datetime <= DateTime.now)
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00221']), status: 400 if ((bk_end_datetime.to_i -  bk_start_datetime.to_i) < (60*60/2)-300)
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00217']), status: 400 if (bk_end_datetime <= bk_start_datetime)
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00215']), status: 400 if (bk_start_hour >= 0 && bk_start_hour < 12)
			# return render json: ApiStatusCodesHelper.setup('E00001', ['AE00216']), status: 400 if (bk_end_hour == 23 && bk_end_minute > 30)
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00218']), status: 400 if ((bk_end_datetime.to_i -  bk_start_datetime.to_i) > (4*60*60))
			reservation_found = Reservation.where(' (table_id = ? and is_deleted = false) and ((start_at between ? and ?) or (end_at between ? and ?)) ', table_found.id.to_s, clean_var_for_sql(bk_start_datetime),clean_var_for_sql(bk_end_datetime),clean_var_for_sql(bk_start_datetime),clean_var_for_sql(bk_end_datetime))
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00214']), status: 400 unless reservation_found.empty?
			new_reservation = Reservation.new(table_id: table_found.id, main_customer_phone: params[:reservingCustomerPhone].to_s, start_at: params[:reservationStartAt], end_at: params[:reservationEndAt],main_customer_name: params[:reservingCustomerName].to_s.strip.split(" ").map(&:capitalize)*' ', no_of_customers: params[:numberOfCustomers], added_by_id: @global_resturant_user['id'])
			if new_reservation.save
				return render json: {
					data: {
						tableNumber: table_found.table_number,
						reservingCustomerName: new_reservation.main_customer_name,
						reservingCustomerPhone: new_reservation.main_customer_phone,
						reservationStartAt: new_reservation.start_at,
						reservationEndAt: new_reservation.end_at,
						reservationRegistrationId: new_reservation.id,
						reservationRegisteredAt: new_reservation.created_at
					},
				}.merge(ApiStatusCodesHelper.setup('I00001', ['R00200'])), status: 200
			else
				return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
			end
		rescue Exception => apiCallExcep
	    	puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
	    	return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
	    ensure
	    	table_found, bk_start_datetime, bk_start_date, bk_start_hour, bk_start_minute, bk_end_datetime, bk_end_date, bk_end_hour, bk_end_minute = nil
	    end
	end

	def list_all_reservations_today
		begin
			return redirect_to "/api/v1/Admin/Reservations?page=#{params[:page].to_s}&sort=#{params[:sort].to_s}&date=#{params[:date].to_s}&tableNumbers=#{params[:tableNumbers]}" if @global_resturant_user['role'] == 'admin'
			(params[:page].to_i <= 1) ? params[:page] = 1 : params[:page] = params[:page].to_i
			(params[:sort].to_s != 'ascending') ? params[:sort] = 'descending' : params[:sort] = 'oldest'
			todays_date = DateTime.now.strftime('%Y-%m-%d')
			reservations_count = Reservation.where("is_deleted = false and DATE(start_at) = ? and DATE(end_at) = ?", todays_date.to_s, todays_date.to_s).select('id').all.count
			if params[:sort].to_s == 'descending'
				sort_as = 'desc'
			else
				sort_as = 'asc'
			end
			all_reservations = ActiveRecord::Base.connection.exec_query("select tab.table_number tableNumber, res.main_customer_name as reservingCustomerName, res.main_customer_phone as reservingCustomerPhone, res.start_at as reservationStartAt, res.end_at as reservationEndAt, res.id as reservationRegistrationId,res.created_at as reservationRegisteredAt from reservations res, tables tab where tab.id = res.table_id and res.is_deleted = false and DATE(res.start_at) = '#{todays_date.to_s}' and DATE(res.end_at) = '#{todays_date.to_s}' order by res.created_at #{sort_as.to_s} limit 10 offset #{((clean_var_for_sql(params[:page]-1)).to_i*10).to_s}").as_json
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
	    	todays_date, all_reservations = nil
	    end
	end

	def delete_reservation
		begin
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00141']), status: 400 if !check_nil_and_empty(params[:reservationRegistrationId])
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00201']), status: 400 if !params[:reservationRegistrationId].to_s.scan(/\D/).empty? || params[:tableNumber].to_s.starts_with?("0")
			todays_date = DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
			reservation_found = Reservation.where(id: params[:reservationRegistrationId].to_i, is_deleted: 0).where('start_at > ?', todays_date.to_s).first
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00010','AE00219','R00404']), status: 400 unless !reservation_found.nil?
			if reservation_found.update(is_deleted: 1, deleted_by_id: @global_resturant_user['id'],deleted_at: Time.now)
				return render json: {
					data: {
						reservationRegistrationId: reservation_found.id,
						reservationRegisteredAt: reservation_found.created_at,
						reservationRemovedAt: reservation_found.deleted_at
					},
				}.merge(ApiStatusCodesHelper.setup('I00001', ['R00210'])), status: 200
			else
				return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
			end
		rescue Exception => apiCallExcep
	    	puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
	    	return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
	    ensure
	    	reservation_found, todays_date = nil
	    end
	end
end
