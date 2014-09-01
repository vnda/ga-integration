class VisitsController < ApplicationController
  def show
    report = GaVisitsReport.new(store.ga_un, Time.parse(params[:week]))
    render json: report
  rescue ArgumentError
    render status: :bad_request, json: { error: 'week is required' }
  rescue GaClient::Unauthorized => e
    render status: :forbidden, json: { error: e.message }
  rescue ActiveRecord::RecordNotFound
    render status: :forbidden, json: { error: 'Invalid token' }
  end
end
