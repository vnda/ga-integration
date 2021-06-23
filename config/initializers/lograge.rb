Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = LogentriesFormatter.new
  config.lograge.custom_options = lambda do |event|
    {
      host: event.payload[:host],
      params: event.payload[:params],
      ga: event.payload[:ga],
    }
  end
end
