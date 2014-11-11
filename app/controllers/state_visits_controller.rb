class StateVisitsController < ApplicationController
  def show
    report = GaStateReport.new(store.ga_un, Time.parse(params[:start])..Time.parse(params[:end]))
    render json: report
  rescue ArgumentError
    render status: :bad_request, json: { error: 'range is required' }
  rescue GaClient::Unauthorized => e
    render status: :forbidden, json: { error: e.message }
  rescue ActiveRecord::RecordNotFound
    render status: :forbidden, json: { error: 'Invalid token' }
  end
end
