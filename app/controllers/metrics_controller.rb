class MetricsController < ApplicationController
  def show
    store = Store.find_by!(token: params[:token])
    report = GaProductReport.new(store.ga_un, params[:id])
    render json: report
  rescue GaProductReport::Unauthorized => e
    render status: :forbidden, json: { error: e.message }
  rescue ActiveRecord::RecordNotFound
    render status: :forbidden, json: { error: 'Invalid token' }
  end
end
