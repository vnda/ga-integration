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

    Rails.logger.debug("Event sent: #{event.inspect}")
  end

  def set_client_id
    ga = if @json['analytics'].present?
        @json['analytics']['_ga']
      elsif @json['extra_fields'].present?
        field = @json['extra_fields'].find { |f| f['name'] == '_ga' }
        field && field['value']
      end
    @client_id = ga.split(".").values_at(2,3).join(".") if ga
    Rails.logger.debug(@client_id ? "CID: #{@client_id}" : 'cid not present')
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
    when 'product-listed' then event.merge(**product_data(prefix: :il1pi), il1nm: @json['list'])
    when 'checkout-1-cart' then event.merge(**product_data, pa: 'checkout', cos: 1)
    when 'checkout-2-shipping-calc' then event.merge(**product_data, pa: 'checkout', cos: 2, col: @json['city_name'])
    when 'checkout-3-shipping-mode' then event.merge(**product_data, pa: 'checkout', cos: 3, col: @json['shipping'])
    when 'checkout-4-address' then event.merge(**product_data, pa: 'checkout', cos: 4)
    when 'checkout-5-payment' then event.merge(**product_data, pa: 'checkout', cos: 5, col: @json['payment'])
    when 'transaction' then event.merge(**product_data(products: @json['items']), **transaction_data)
    when 'cart-created' then event.merge(ea: 'Carrinho Criado', el: @json['reference'])
    when 'shipping-caculated' then event.merge(ea: 'Calculo de Frete', el: @json['zip'])
    when 'capcha-loaded' then event.merge(ea: 'Captcha exibido', el: @json['ip'])
    when 'capcha-verified' then event.merge(ea: 'Captcha verificado', el: @json['ip'])
    else raise ArgumentError, "no such event: #{@event_type.inspect}"
    end
  end

  def product_data(products: @json['resource'], prefix: :pr)
    products = [products] unless products.is_a?(Array)
    hash = {}
    products.each_with_index do |item, index|
      key = "#{prefix}#{index + 1}"
      hash = hash.merge(
        "#{key}id" => item['product']['reference'],
        "#{key}nm" => item['product']['name'].presence || item['product']['product_name'],
        "#{key}pr" => item['product']['price'],
        "#{key}va" => item['product']['variant_name'],
        "#{key}qt" => item['product']['quantity'],
        "#{key}ps" => item['product']['position'],
        "#{key}ca" => product_category(item),
      )
      puts "Produto : #{hash}"
    end
    hash.reject { |k, v| v.blank? }.symbolize_keys
  end

  def product_category(item)
    properties = item['product']['category_tags']
    properties.each do |p|
      return p['name'] if p['tag_type'] == "product_category"
    end
    return nil
  end

  def transaction_data
    if @json['status'] == 'canceled'
      { pa: 'refund' }
    else
      {
        pa: 'purchase',
        ti: @json['code'],
        ta: @json['email'],
        tr: @json['total'],
        ts: @json['shipping_price']
      }
    end
  end
end
