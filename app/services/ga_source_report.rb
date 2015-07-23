class GaSourceReport
  HEADER_NAMES = {
    'ga:yearMonth' => :year_month,
    'ga:sessions' => :sessions,
    'ga:users' => :users,
    'ga:pageviews' => :pageviews,
    'ga:transactions' => :transactions,
    'ga:source' => :source,
    'ga:medium' => :medium,
    'ga:transactionRevenue' => :revenue,
    'ga:uniquePurchases' => :unique_purchases
  }.freeze

  def initialize(property_id, range)
    @client = GaClient.new(property_id)
    @range = range
  end

  def as_json(*)
    report
  end

  private
dimensions=ga:source,ga:medium
metrics=ga:sessions,ga:transactionRevenue,ga:transactions,ga:uniquePurchases
sort=-ga:sessions

  def report
    @report ||= begin
      report_params = {
        'start-date' => @range.begin.strftime('%Y-%m-%d'),
        'end-date' => @range.end.strftime('%Y-%m-%d'),
        'filters' => 'ga:transactions!=0',
        'metrics' => ['ga:sessions', 'ga:users', 'ga:pageviews', 'ga:transactions', 'ga:transactionRevenue', 'ga:uniquePurchases'].join(?,)
      }
      by_day_params = report_params.merge('dimensions' => 'ga:source,ga:medium', 'sort' => '-ga:transactions')
      total_data, by_month_data = @client.batch_report(report_params, by_day_params)

      { by_month: process_data(by_month_data), total: process_data(total_data).first }
    end
  end

  def process_data(data)
    headers = data.column_headers.map { |ch| HEADER_NAMES[ch.name] }
    data.rows.map { |row| headers.zip(row.map(&:to_s)).to_h }
  end
end
