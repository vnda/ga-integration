class GaProductReport
  def initialize(property_id, product_sku)
    @client = GaClient.new(property_id)
    @sku = product_sku
  end

  def as_json(*)
    stats_data, position_data = @client.batch_report(
      stats_request_params, position_per_list_request_params
    )
    stats = stats_process_result(stats_data)
    position_per_list = position_per_list_process_result(position_data)

    stats.merge(avg_position_per_list: position_per_list)
  end

  private

  def build_request(params)
    {
      'start-date' => '7daysAgo',
      'end-date'   => 'today',
      'filters'    => "ga:productSku==#{@sku}"
    }.merge(params.stringify_keys)
  end

  def stats_request_params
    build_request metrics: [
      'ga:productDetailViews', 'ga:productListViews', 'ga:productAddsToCart',
      'ga:productRemovesFromCart'
    ].join(?,)
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
    build_request(
      dimensions: 'ga:productListName,ga:productListPosition',
      metrics: 'ga:productListViews'
    )
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
end
