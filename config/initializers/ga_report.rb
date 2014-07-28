GaReport.tap do |config|
  config.p12_key_file = Rails.root.join('config/google_api.p12')
  config.service_account_email = begin
    File.read('config/google_api_account_email').strip
  rescue Errno::ENOENT => e
    Rails.logger.error('Failed to load GaReport configuration: ' + e.message)
  end
end
