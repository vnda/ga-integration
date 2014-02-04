class SenderController < ActionController::Base

  def send_transaction
    store = Store.where(token: params["token"]).first
    json = JSON.parse(request.body.read)

    if(store and json)
    	GaSender.new(json, store).send!
	  end
	  render json: 'ok'
  end

end
