class GaStateReport
  HEADER_NAMES = {
    'ga:yearMonth' => :year_month,
    'ga:region' => :region,
    'ga:country' => :country,
    'ga:sessions' => :sessions,
    'ga:users' => :users,
    'ga:pageviews' => :pageviews,
    'ga:transactions' => :transactions
  }.freeze

  def initialize(property_id, range)
    @client = GaClient.new(property_id)
    @range = range
  end

  def as_json(*)
    report
  end

  private

  def report
    @report ||= begin
      report_params = {
        'start-date' => @range.begin.strftime('%Y-%m-%d'),
        'end-date' => @range.end.strftime('%Y-%m-%d'),
        'metrics' => ['ga:sessions', 'ga:users', 'ga:pageviews', 'ga:transactions'].join(?,),
        'filters' => 'ga:country==Brazil'
      }
      by_day_params = report_params.merge('dimensions' => ['ga:yearMonth', 'ga:region', 'ga:country'].join(?,), 'sort' => '-ga:sessions')
      total_data, by_month_data = @client.batch_report(report_params, by_day_params)

      { by_month: process_data(by_month_data), total: process_data(total_data).first }
    end
  end

  def process_data(data)
    headers = data.column_headers.map { |ch| HEADER_NAMES[ch.name] }
    data.rows.map { |row| headers.zip(row.map(&:to_s)).to_h }
  end
end
