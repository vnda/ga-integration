class GaProductReport
  class Error < StandardError; end
  class Unauthorized < Error; end

  def initialize(property_id, product_sku)
    @property_id = property_id
    @sku = product_sku
  end

  def as_json(*)
    results = []
    batch = Google::APIClient::BatchRequest.new do |result|
      results << result
    end
    batch.add(build_request(stats_request_params))
    batch.add(build_request(position_per_list_request_params))

    client.execute(batch)
    stats_data, position_data = results.map { |r| result_data(r) }
    stats = stats_process_result(stats_data)
    position_per_list = position_per_list_process_result(position_data)

    stats.merge(avg_position_per_list: position_per_list)
  end

  private

  def build_request(params)
    {
      api_method: analytics.data.ga.get,
      parameters: {
        'ids'        => 'ga:' + view_id,
        'start-date' => '7daysAgo',
        'end-date'   => 'today',
        'filters'    => "ga:productSku==#{@sku}"
      }.merge(params.stringify_keys)
    }
  end

  def stats_request_params
    {
      metrics: [
        'ga:productDetailViews', 'ga:productListViews', 'ga:productAddsToCart',
        'ga:productRemovesFromCart'
      ].join(?,)
    }
  end

  def stats_process_result(data)
    headers = data.column_headers.map(&:name)
    row = data.rows.empty? ? ([0] * headers.size) : data.rows.first
    hash = headers.zip(row.map(&:to_i)).to_h
    hash.transform_keys do |k|
      case k
      when 'ga:productDetailViews'     then :detail_views
      when 'ga:productListViews'       then :list_views
      when 'ga:productAddsToCart'      then :adds_to_cart
      when 'ga:productRemovesFromCart' then :removes_from_cart
      end
    end
  end

  def position_per_list_request_params
    {
      dimensions: 'ga:productListName,ga:productListPosition',
      metrics: 'ga:productListViews'
    }
  end

  def position_per_list_process_result(data)
    # get the column index of each header
    headers = data.column_headers.map(&:name)
    list_name_i, pos_i, views_i = [
      'ga:productListName', 'ga:productListPosition', 'ga:productListViews'
    ].map { |h| headers.index(h) }

    data.rows
      .group_by { |row| row[list_name_i] }
      .map do |(list_name, rows)|
        total_views = rows.sum { |row| row[views_i].to_f }
        weighted_avg = rows.sum do |row|
          weigth = row[views_i].to_f / total_views
          row[pos_i].to_f * weigth
        end
        [list_name, weighted_avg]
      end.to_h
  end

  def result_data(result)
    if result.error?
      klass = (result.status == 403) ? Unauthorized : Error
      raise klass, "#{result.status}: #{result.error_message}"
    else
      result.data
    end
  end

  def view_id
    key = "analytics_view_id_#{@property_id}_#{service_account_email}"
    Rails.cache.fetch(key) do
      res = client.execute(api_method: analytics.management.profiles.list, parameters: {
        'accountId' => '~all',
        'webPropertyId' => '~all',
        'fields' => 'items(id,webPropertyId)'
      })
      found_id = res.data.items.find { |i| i.web_property_id == @property_id }.try(:id)

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
        issuer: config[:service_account_email],
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
