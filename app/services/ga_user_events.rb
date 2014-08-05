class GaUserEvents
  def initialize(property_id, user_id)
    @client = GaClient.new(property_id)
    @user_id = user_id
  end

  def as_json(*)
    data = @client.report(
      'dimensions' => 'ga:dateHour,ga:minute,ga:ProductSku',
      'metrics'    => 'ga:productAddsToCart,ga:productDetailViews',
      'filters'    => "ga:dimension1==#{@user_id}",
      'sort'       => '-ga:dateHour,-ga:minute',
      'start-date' => '2005-01-01',
      'end-date'   => 'today',
    )
    headers = data.column_headers.map(&:name)
    dh, m, sku, adds, details = %w[
      ga:dateHour ga:minute ga:ProductSku ga:productAddsToCart
      ga:productDetailViews
    ].map { |h| headers.index(h) }

    data.rows.map do |row|
      time = Time.strptime(row[dh] + row[m], '%Y%m%d%H%M').in_time_zone
      event =
        if row[adds].to_i != 0 then :add_to_cart
        elsif row[details].to_i != 0 then :view_details
        end
      %i[time event reference].zip([time, event, row[sku]]).to_h
    end
  end
end
