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

    Rails.logger.info("Event sent: #{event.inspect}")
  end

  def set_client_id
    ga_cookie = @json['extra_fields'].select{|field| field['name'] == '_ga'}.first if @json['extra_fields']
    ga_cookie_value = ga_cookie['value'] if ga_cookie
    @client_id = ga_cookie_value.split(".").values_at(2,3).join(".") if ga_cookie_value
    Rails.logger.info(@client_id ? "CID: #{@client_id}" : 'cid not present')
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
    when 'product-viewed' then event.merge(product_data).merge(t: 'event', pa: 'detail')
    when 'product-added-to-cart' then event.merge(product_data).merge(t: 'event', pa: 'add')
    when 'product-removed-from-cart' then event.merge(product_data).merge(t: 'event', pa: 'remove')
    when 'cart-created' then event.merge(ea: 'Carrinho Criado', el: @json['reference'])
    when 'shipping-caculated' then event.merge(ea: 'Calculo de Frete', el: @json['zip'])
    when 'capcha-loaded' then event.merge(ea: 'Captcha exibido', el: @json['ip'])
    when 'capcha-verified' then event.merge(ea: 'Captcha verificado', el: @json['ip'])
    else raise ArgumentError, "no such event: #{@event_type.inspect}"
    end
  end

  def product_data
    {
      pr1id: @json['reference'],
      pr1nm: @json['name'],
      pr1pr: @json['price'],
      pr1va: @json['variant_name'],
      pr1qt: @json['quantity']
    }.reject { |k, v| v.blank? }
  end
end
