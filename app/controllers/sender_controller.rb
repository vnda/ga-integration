class SenderController < ActionController::Base

  before_action :set_store_and_json

  def send_stathat
    if (@store and @json)
      StatHatSender.new(@json, @store).send! if @store.stat_hat_token?
    end
      render json: 'ok'
  end

  def send_transaction
    if(@store and @json)
    	@store.ga_un? ? UniversalAnalyticsSender.new(@json, @store).send! : GaSender.new(@json, @store).send!
    end
	  render json: 'ok'
  end

  def send_event
  	if(@store and @json and @store.ga_un?)
    	UniversalAnalyticsEventSender.new(@json, @store, params[:event_type]).send!
    end

  	render json: 'ok'
  end

  private

  def set_store_and_json
    @store = Store.where(token: params["token"]).first
    @json = JSON.parse(request.body.read)
  end
end
