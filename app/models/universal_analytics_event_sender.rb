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
    if @json['analytics'] && @json['analytics']['_ga'].present?
      @client_id = @json['analytics']['_ga'].split(".").values_at(2,3).join(".")
    end
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
    when 'product-viewed' then event.merge(**product_data, ea: 'Produto Visualizado', pa: 'detail')
    when 'product-added-to-cart' then event.merge(**product_data, ea: 'Adicionado ao Carrinho', pa: 'add')
    when 'product-removed-from-cart' then event.merge(**product_data, ea: 'Removido do Carrinho', pa: 'remove')
    when 'product-listed' then event.merge(**product_data(:il1pi), il1nm: @json['list'])
    when 'cart-created' then event.merge(ea: 'Carrinho Criado', el: @json['reference'])
    when 'shipping-caculated' then event.merge(ea: 'Calculo de Frete', el: @json['zip'])
    when 'capcha-loaded' then event.merge(ea: 'Captcha exibido', el: @json['ip'])
    when 'capcha-verified' then event.merge(ea: 'Captcha verificado', el: @json['ip'])
    else raise ArgumentError, "no such event: #{@event_type.inspect}"
    end
  end

  def product_data(prefix=:pr)
    prods = @json['resource']
    prods = [prods] unless prods.is_a?(Array)
    hash = {}
    prods.each_with_index do |prod, index|
      key = "#{prefix}#{index + 1}"
      hash = hash.merge(
        "#{key}id" => prod['reference'],
        "#{key}nm" => prod['name'],
        "#{key}pr" => prod['price'],
        "#{key}va" => prod['variant_name'],
        "#{key}qt" => prod['quantity'],
        "#{key}ps" => prod['position'],
      )
    end
    hash.reject { |k, v| v.blank? }.symbolize_keys
  end
end
