class MetricsController < ApplicationController
  def show
    store = Store.find(params[:store_id])
    report = GaProductReport.new(store.ga_un, params[:id])
    render json: report
  rescue GaProductReport::Unauthorized => e
    render status: :forbidden, json: { error: e.message }
  end
end
