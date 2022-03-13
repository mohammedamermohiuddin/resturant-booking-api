module GenericConditionalHelper

    def check_nil_and_empty variable
        return !variable.nil? && !variable.to_s.empty?
    end

    def validate_phone(generic_phone_str)
        begin
            generic_phone_numbers_only_str = generic_phone_str.to_s.tr('^0-9', '')
            if check_nil_and_empty(generic_phone_str) && generic_phone_numbers_only_str.length == 10 && generic_phone_numbers_only_str == generic_phone_str.to_s
                return true
            else
                return false
            end
        rescue Exception => phoneParseExcep
            return false
        end
    end

  def clean_var_for_sql(var_value)
        return nil unless !var_value.nil?
        return var_value.to_s.gsub(";","").gsub("'","''").gsub("*","").gsub("--","").gsub("/*","").gsub("*/","").gsub("=","").strip.split.join(" ")
  end

end
