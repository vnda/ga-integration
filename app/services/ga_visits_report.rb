class GaVisitsReport
  def initialize(property_id, week=Time.now)
    @client = GaClient.new(property_id)
    @week = week
  end

  def as_json(*)
    names = { 'ga:dayOfWeek' => :week_day, 'ga:sessions' => :sessions, 'ga:users' => :users }
    headers = data.column_headers.map { |ch| names[ch.name] }
    data.rows.map { |row| headers.zip(row.map(&:to_i)).to_h }
  end

  def data
    @data ||= @client.report(
      'start-date' => @week.beginning_of_week.strftime('%Y-%m-%d'),
      'end-date' => @week.end_of_week.strftime('%Y-%m-%d'),
      'dimensions' => 'ga:dayOfWeek',
      'metrics' => ['ga:sessions', 'ga:users'].join(?,),
      'sort' => 'ga:dayOfWeek'
    )
  end
end
