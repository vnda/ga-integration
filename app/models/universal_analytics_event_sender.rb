class UniversalAnalyticsEventSender

	ENDPOINT_URL = 'http://www.google-analytics.com/collect'
	DEFAULT_CLIENT_ID = '555'

  def initialize(json, store, event_type)
    @json = json
    @store = store
    @event_type = event_type
  end

	def send!
		set_client_id
		send_event
	end

	private

	def send_event
		event = create_event
		RestClient.get(ENDPOINT_URL, params: event)

		puts "Event sent"
    puts event
	end

	def set_client_id
    if @json['analytics'] && @json['analytics']['_ga'].present?
  		@client_id = @json['analytics']['_ga'].split(".").values_at(2,3).join(".")
    end
    @client_id ? puts("CID: #{@client_id}") : puts("cid not present")
  end

  def create_event
    event = {
      v: 1,
      tid: @store.ga_un,
      cid: @client_id || DEFAULT_CLIENT_ID,
      t: 'event',
      ec: 'VNDA Ecommerce'
    }

    case @event_type
    when 'product-viewed'
      event.merge(
        ea: 'Produto Visualizado',
        pa: 'detail',
        pr1id: @json['resource']['reference'],
        pr1nm: @json['resource']['name'],
        pr1pr: @json['resource']['price']
      )
    when 'product-added-to-cart'
      event.merge(
        ea: 'Adicionado ao Carrinho',
        pa: 'add',
        pr1id: @json['resource']['reference'],
        pr1nm: @json['resource']['name'],
        pr1pr: @json['resource']['price'],
        pr1va: @json['resource']['variant_name'],
        pr1qt: @json['resource']['quantity']
      )
    when 'cart-created' then event.merge(ea: 'Carrinho Criado', el: @json['reference'])
    when 'shipping-caculated' then event.merge(ea: 'Calculo de Frete', el: @json['zip'])
    when 'capcha-loaded' then event.merge(ea: 'Captcha exibido', el: @json['ip'])
    when 'capcha-verified' then event.merge(ea: 'Captcha verificado', el: @json['ip'])
    end
  end
end
