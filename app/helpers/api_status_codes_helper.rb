module ApiStatusCodesHelper

	def self.get_status_code_data(status_code)
		status_code_hash = {
			# Status Code Helper Errors
				E04001: 'Missing Status Code Parameters',


			# Master Status Codes
				I00001: 'The request was processed successfully.',
				E00001: 'The request could not be processed as there were errors.',
			
			# General Informational Codes
				I00100: 'Pagniation applied.',

			# Authentication Codes
				AI00006: 'The user is valid and the token was generated successfully.',
				AI00007: 'The provided token is valid.',
				AI00008: 'Token destroyed successfully.',
				AE00007: 'Employee number or password is invalid and/or the transaction key or API key is invalid.',
				AE00010: 'No records have been found that match your query or the record have already been deleted or query does not meet the required criteria.',
				AE00123: 'No access token provided or the provided access token is invalid or has expired.',
				AE00139: 'Access denied. Access Token does not have correct permissions for this API.',
				AE00141: 'The required parameters for this request was not found in payload.',
				AE00143: 'User is not active.',
				AE00144: 'Employee number entered is not as per the standard, can consist only 4 digits.',
				AE00145: 'Employee number already used.',
				AE00146: 'Password entered is not as per the standard, can contain 8 or more characters, a digit, a lower case character, an upper case character and a symbol.',
				AE00148: 'Name cannot have special characters.',
				AE00149: 'Invalid phone entered.',
				AE00150: 'Employee role can only be selected as Admin or Employee.',
				AE00201: 'Table number entered is not as per the standard, can only be a number greater than 0.',
				AE00202: 'Number of seats entered is not as per the standard, can only be a number and can be between 1 and 12 only.',
				AE00203: 'Table number already used.',
				AE00204: 'Table number not found or already deleted.',
				AE00205: 'Table cannot be deleted, it has reservations.',
				AE00210: 'Reservation failed, number of customers exceed the number of the seats on table that is trying to br reserved.',
				AE00211: 'Reservation start at entered is not as per the standard, the format should be yyyy-mm-dd HH:MM:SS.',
				AE00212: 'Reservation end at entered is not as per the standard.',
				AE00213: 'Invalid format, the format should be yyyy-mm-dd hh24:mm.',
				AE00214: 'Reservation failed, reservation already exists between the selected time slot for this table.',
				AE00215: 'Reservation failed, reservation time out of bound, resturant is only open from 12:00 PM to 11:59 PM.',
				AE00216: 'Reservation failed, reservation end at is very close to the closing time of the resturant.',
				AE00217: 'Reservation failed, reservation end at cannot be equal or lesser than reservation start at.',
				AE00218: 'Reservation failed, one reservation can me made for maximum of 4 hours.',
				AE00219: 'Reservation not found or reservation trying to be deleted is not from the future.',
				AE00220: 'Reservation failed, reservation start at should be greater than current time.',
				AE00221: 'Reservation failed, one reservation can me made for minimum of 25 minutes.',
				AE00404: 'Unable to validate/find user with provided information.',

			# User Success Codes
				U00200: 'User registered successfully.',

			# Table Success Codes
				T00100: 'Tables retreived successfully.',
				T00200: 'Table registered successfully.',
				T00210: 'Table removed successfully.',
				T00404: 'No tables found.',

			# Reservation Success Codes
				R00100: 'Reservations retreived successfully.',
				R00200: 'Reservation registered successfully.',
				R00210: 'Reservation removed successfully.',
				R00404: 'No reservations found.',


			# Server Related
				E00500: 'Internal Server Error.',
				E00404: 'Service not found.',
				E00400: 'Invalid parameters sent.',
				E00101: 'Please make sure query parameters are sent correctly.',
				E00503: 'The server is under maintenance, we will be back soon.',

		}

		return {
			code: status_code,
			description: status_code_hash[status_code.to_sym]
		}
	end
	def self.setup(msc, status_codes = [])
		# msc = MASTER STATUS CODE

		# Resolve the master_status_code data
		if msc.nil? || msc == '' || status_codes == nil || status_codes.length == 0
			trx_status = get_status_code_data('E00001')
			err_status = get_status_code_data('E04001')

			response = {
				transactionStatus: trx_status[:code],
				transactionDescription: trx_status[:description],
				statusCodes: [
			        {
						statusCode: err_status[:code],
						statusDescription: err_status[:description]
					}
				]
			}
		else
			trx_status = get_status_code_data(msc)
			status_codes_array_object = status_codes_array_processor(status_codes)

			response = {}

			response = {
				transactionStatus: trx_status[:code],
				transactionDescription: trx_status[:description],
				statusCodes: status_codes_array_object
			}
		end

		return response
	end

	def self.status_codes_array_processor(status_codes_array)
		response = Array.new
		if status_codes_array.length == 0
		else
			status_codes_array.each do |status_code|
				status_detail_data = get_status_code_data(status_code)
				status_entry = {
						statusCode: status_detail_data[:code],
						statusDescription: status_detail_data[:description],
					}
				response.push(status_entry)
			end
		end
		return response
	end

end