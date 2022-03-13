class AuthenticationController < ApplicationController
	before_action :authenticate_request!, except: [:authenticate_user_login, :invalid_route]

	def authenticate_user_login
		begin
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00141']), status: 400 if (!(check_nil_and_empty(params[:employeeNumber])) || !(check_nil_and_empty(params[:password])))
			resturant_user = User.find_for_database_authentication(employee_no: params[:employeeNumber].to_s)
			if !resturant_user.nil? && resturant_user.valid_password?(params[:password])
				resturant_user.update(current_sign_in_at: DateTime.current)
				return render json: generate_token(resturant_user).merge(ApiStatusCodesHelper.setup('I00001', ['AI00006'])), status: 200
			else
				return render json: ApiStatusCodesHelper.setup('E00001', ['AE00007']), status: 403
			end
		rescue Exception => apiCallExcep
			puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
			return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
		ensure
			resturant_user = nil
		end
	end

	def check_token_is_valid
		begin
			return render json: {
				data: {
					authToken: request.headers['Authorization'].gsub('Bearer ',''),
					validityInSeconds: (@auth_token[:exp] - DateTime.current.to_time.to_i)
				},
			}.merge(ApiStatusCodesHelper.setup('I00001', ['AI00007'])), status: 200
	    rescue Exception => apiCallExcep
	    	puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
	    	return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
	    end
	end

	def destroy_token
		begin
			@global_resturant_user.update(last_sign_in_at: @global_resturant_user[:current_sign_in_at], last_sign_in_ip: @global_resturant_user[:current_sign_in_ip], current_sign_in_at: nil, current_sign_in_ip: nil)
			return render json: {
				data: {
					authToken: nil,
					validityInSeconds: nil
				},
			}.merge(ApiStatusCodesHelper.setup('I00001', ['AI00008'])), status: 200
	    rescue Exception => apiCallExcep
	    	puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
	    	return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
	    end
	end

	def invalid_route
		begin
			return render json: ApiStatusCodesHelper.setup('E00001', ['E00404']), status: 404
	    rescue Exception => apiCallExcep
	    	puts apiCallExcep.inspect + ' backtrace: ' + apiCallExcep.backtrace.to_s
	    	return render json: ApiStatusCodesHelper.setup('E00001', ['E00500']), status: 500
	    end
	end
end
