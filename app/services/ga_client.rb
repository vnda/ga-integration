class GaClient
  class Error < StandardError; end
  class Unauthorized < Error; end

  def initialize(property_id)
    @view_id = view_id_for_property(property_id)
  end

  def report(parameters)
    result_data(client.execute(build_request(parameters)))
  end

  def batch_report(*requests)
    return [] if requests.empty?
    results = []
    batch = Google::APIClient::BatchRequest.new do |result|
      results << result
    end

    requests.each do |params|
      batch.add(build_request(params))
    end
    client.execute(batch)
    results.map { |r| result_data(r) }
  end

  private

  def build_request(params)
    {
      api_method: analytics.data.ga.get,
      parameters: { ids: "ga:#{@view_id}" }.merge(params)
    }
  end

  def result_data(result)
    if result.error?
      klass = (result.status == 403) ? Unauthorized : Error
      raise klass, "#{result.status}: #{result.error_message}"
    else
      result.data
    end
  end

  def view_id_for_property(property_id)
    key = "analytics_view_id_#{property_id}_#{service_account_email}"
    Rails.cache.fetch(key) do
      res = client.execute(api_method: analytics.management.profiles.list, parameters: {
        'accountId' => '~all',
        'webPropertyId' => '~all',
        'fields' => 'items(id,webPropertyId)'
      })
      found_id = res.data.items.find { |i| i.web_property_id == property_id }.try(:id)

      raise Unauthorized, "Service account has no access to the property" if found_id.nil?
      found_id
    end
  end

  def client
    @client ||= begin
      c = Google::APIClient.new(application_name: Rails.application.engine_name)

      key = Google::APIClient::KeyUtils.load_from_pkcs12(p12_key, 'notasecret')

      c.authorization = Signet::OAuth2::Client.new(
        token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
        audience: 'https://accounts.google.com/o/oauth2/token',
        scope: 'https://www.googleapis.com/auth/analytics.readonly',
        issuer: service_account_email,
        signing_key: key
      )

      c.authorization.fetch_access_token!
      c
    end
  end

  def analytics
    Rails.cache.fetch('analytics_v3') do
      client.discovered_api('analytics', 'v3')
    end
  end

  def service_account_email; config[:service_account_email] end
  def p12_key; config[:p12_key] end

  def config
    Rails.application.config.google_api
  end
end
