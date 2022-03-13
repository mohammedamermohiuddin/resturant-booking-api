Rails.application.routes.draw do
  post '/api/v1/Authenticate', to: 'authentication#authenticate_user_login'
  get '/api/v1/Token/Validate', to: 'authentication#check_token_is_valid'
  delete '/api/v1/Logout', to: 'authentication#destroy_token'
  post '/api/v1/Register/Employee', to: 'admin#add_employee'
  get '/api/v1/Tables', to: 'admin#list_all_tables'
  get '/api/v1/Admin/Reservations', to: 'admin#list_all_reservations'
  post '/api/v1/Register/Table', to: 'admin#add_table'
  delete '/api/v1/Remove/Table/:tableNumber', to: 'admin#delete_table'
  get '/api/v1/Reservations', to: 'reservation#list_all_reservations_today'
  post '/api/v1/Register/Reservation', to: 'reservation#add_reservation'
  delete '/api/v1/Remove/Reservation/:reservationRegistrationId', to: 'reservation#delete_reservation'
  match '*path' , to: 'authentication#invalid_route', via: [:get, :post, :put, :delete], as: 'invalid_route'
end
