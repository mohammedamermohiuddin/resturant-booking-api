module AuthorizationHelper
	# Authenticate a request, before any other request.
	def authenticate_request!
		unless authenticate_token
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00123']), status: 403
		end
		unless @auth_token.empty?
			@global_resturant_user = User.find_by(id: @auth_token[:user_id])
			return render json: ApiStatusCodesHelper.setup('E00001', ['AE00123']), status: 403 if @auth_token[:iat] != @global_resturant_user.current_sign_in_at.to_i
			unless !@global_resturant_user.nil?
				return render json: ApiStatusCodesHelper.setup('E00001', ['AE00123']), status: 403
			end
		end
		@auth_token
			rescue JWT::VerificationError, JWT::DecodeError, JWT::ExpiredSignature
				return render json: ApiStatusCodesHelper.setup('E00001', ['AE00123']), status: 403
	end

	def authenticate_token
		return @auth_token unless http_token
		@auth_token = JsonWebToken.decode(@http_token)
	end

	# Returns the token from Header
	def http_token
		@http_token ||= if request.headers['Authorization'].present?
							request.headers['Authorization'].split(' ').last
						end
	end

	def generate_token(user)
		return nil unless user
		return {
			authToken: JsonWebToken.encode({ user_id: user.id, user_role: user.role, iat: user.current_sign_in_at.to_i, exp: user.current_sign_in_at.to_time.to_i + + (8*60*60) }),
			validityInSeconds: 8*60*60
		}
	end

	def check_access
		return render json: ApiStatusCodesHelper.setup('E00001', ['AE00139']), status: 403 if params[:controller] == 'admin' && @global_resturant_user['role'] != 'admin'
	end
end