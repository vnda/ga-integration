class SenderController < ActionController::Base
  before_action :set_store_and_json

  def send_transaction
    if @store && @json
      @store.ga_un? ? UniversalAnalyticsSender.new(@json, @store).send! : GaSender.new(@json, @store).send!
    end
    render json: 'ok'
  end

  def send_event
    if @store && @json && @store.ga_un?
      @ga_payload = UniversalAnalyticsEventSender.new(@json, @store, params[:event_type]).send!
    end

    render json: 'ok'
  end

  private

  def set_store_and_json
    @store = Store.where(token: params["token"]).first
    @json = JSON.parse(request.body.read)
  end

  def append_info_to_payload(payload)
    super
    payload[:host] = @store&.site
    payload[:ga] = @ga_payload
  end
end
