module GaReport
  extend self
  mattr_accessor :service_account_email, :p12_key_file

  def report(view_id)
    metrics = [
      'ga:productDetailViews',
      'ga:productListViews',
      'ga:productAddsToCart',
      'ga:productRemovesFromCart'
    ]
    # Parameters doc: https://developers.google.com/analytics/devguides/reporting/core/v3/reference#q_summary
    client.execute(api_method: analytics.data.ga.get, parameters: {
      'ids'        => 'ga:' + view_id,
      'start-date' => '2014-07-01',
      'end-date'   => '2014-07-28',
      'dimensions' => 'ga:productSku',
      'metrics'    => metrics.join(?,)
    }).data
  end

  def view_id_for_property(property_id)
    key = "analytics_view_id_#{property_id}_#{service_account_email.hash}"
    if cached = Rails.cache.read(key)
      return cached
    end

    res = client.execute(api_method: analytics.management.profiles.list, parameters: {
      'accountId' => '~all',
      'webPropertyId' => '~all',
      'fields' => 'items(id,webPropertyId)'
    })
    found_id = res.data.items.find { |i| i.web_property_id == property_id }.try(:id)

    if found_id
      Rails.cache.write(key, found_id)
      found_id
    end
  end

  private

  def client
    @client ||= begin
      c = Google::APIClient.new(application_name: Rails.application.engine_name)

      key = Google::APIClient::KeyUtils.load_from_pkcs12(p12_key_file, 'notasecret')

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
end
