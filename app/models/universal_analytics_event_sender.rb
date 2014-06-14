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
		ga_cookie = @json['extra_fields'].select{|field| field['name'] == '_ga'}.first if @json['extra_fields']
		ga_cookie_value = ga_cookie['value'] if ga_cookie
		@client_id = ga_cookie_value.split(".").values_at(2,3).join(".") if ga_cookie_value
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
        t: 'event',
        pa: 'detail',
        pr1id: @json['reference'],
        pr1nm: @json['name'],
        pr1pr: @json['price']
      )
    when 'product-added-to-cart'
      event.merge(
        t: 'event',
        pa: 'add',
        pr1id: @json['reference'],
        pr1nm: @json['name'],
        pr1pr: @json['price'],
        pr1va: @json['variant_name'],
        pr1qt: @json['quantity']
      )
    when 'cart-created' then event.merge(ea: 'Carrinho Criado', el: @json['reference'])
    when 'shipping-caculated' then event.merge(ea: 'Calculo de Frete', el: @json['zip'])
    end
  end
end
