class UserEventsController < ApplicationController
  def show
    store = Store.find_by!(token: params[:token])
    return head :forbidden unless store.ga_un?
    render json: GaUserEvents.new(store.ga_un, params[:id])
  end
end
