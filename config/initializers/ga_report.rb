GaReport.tap do |config|
  config.p12_key_file = Rails.root.join('config/google_api.p12')
  config.service_account_email = File.read('config/google_api_account_email').strip
end
