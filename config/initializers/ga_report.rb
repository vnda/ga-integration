GaReport.tap do |config|
  config.p12_key = Base64.strict_decode64(ENV['GOOGLE_API_P12']) rescue nil
  config.service_account_email = ENV['GOOGLE_API_ACCOUNT_EMAIL']
end
