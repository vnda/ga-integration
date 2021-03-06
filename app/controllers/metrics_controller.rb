class MetricsController < ApplicationController
  def show
    report = GaProductReport.new(store.ga_un, params[:id])
    render json: report
  rescue GaClient::Unauthorized => e
    render status: :forbidden, json: { error: e.message }
  rescue ActiveRecord::RecordNotFound
    render status: :forbidden, json: { error: 'Invalid token' }
  end
end
