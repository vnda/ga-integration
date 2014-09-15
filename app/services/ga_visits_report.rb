class GaVisitsReport
  HEADER_NAMES = {
    'ga:dayOfWeek' => :week_day,
    'ga:sessions' => :sessions,
    'ga:users' => :users,
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
        'metrics' => ['ga:sessions', 'ga:users', 'ga:transactions'].join(?,)
      }
      by_day_params = report_params.merge('dimensions' => 'ga:dayOfWeek', 'sort' => 'ga:dayOfWeek')
      week_data, by_day_data = @client.batch_report(report_params, by_day_params)

      { by_day: process_data(by_day_data), total: process_data(week_data).first }
    end
  end

  def process_data(data)
    headers = data.column_headers.map { |ch| HEADER_NAMES[ch.name] }
    data.rows.map { |row| headers.zip(row.map(&:to_i)).to_h }
  end
end
