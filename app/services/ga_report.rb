class GaReport
  mattr_accessor :service_account_email, :p12_key_file, instance_writer: false

  def initialize(view_id)
    @view_id = view_id
  end

  def report
    metrics = [
      'ga:productDetailViews',
      'ga:productListViews',
      'ga:productAddsToCart',
      'ga:productRemovesFromCart'
    ]
    # Parameters doc: https://developers.google.com/analytics/devguides/reporting/core/v3/reference#q_summary
    client.execute(api_method: analytics.data.ga.get, parameters: {
      'ids'        => 'ga:' + @view_id,
      'start-date' => '2014-07-01',
      'end-date'   => '2014-07-28',
      'dimensions' => 'ga:productSku',
      'metrics'    => metrics.join(?,)
    })
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
