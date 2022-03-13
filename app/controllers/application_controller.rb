class ApplicationController < ActionController::API
	include AuthorizationHelper
	include GenericConditionalHelper
end
