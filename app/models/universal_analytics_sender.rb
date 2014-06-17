class UniversalAnalyticsSender

	ECOMMERCE_TRACKING_URL = 'http://www.google-analytics.com/collect'
	DEFAULT_CLIENT_ID = '555'

  def initialize(json, store)
    @json = json
    @store = store
    @multiplier = json['status'] == 'canceled' ? -1 : 1
  end

	def send!
		return if(@json['status'] == 'confirmed')
		set_client_id
		send_items
		send_transaction
	end

	private 

	def set_client_id
		ga_cookie = @json['extra_fields'].select{|field| field['name'] == '_ga'}.first
		ga_cookie_value = ga_cookie['value'] if ga_cookie
		@client_id = ga_cookie_value.split(".").values_at(2,3).join(".") if ga_cookie_value
    @client_id ? puts("CID: #{@client_id}") : puts("cid not present")
  end

	def send_transaction
		transaction = {
      v: 1,
      tid: @store.ga_un,
      cid: @client_id || DEFAULT_CLIENT_ID, 
      t: 'transaction',
      ti: @json["code"],
      ta: @json['email'],
      tr: '%.2f' % (@json['total'].to_f * @multiplier), 
      tt: 0.0,
      ts: @json['shipping_price']
    }
    
		RestClient.get(ECOMMERCE_TRACKING_URL, params: transaction)

		puts "Transaction: #{@json["code"]}, #{'%.2f' % (@json['total'].to_f * @multiplier)}, #{@store.name}, #{0.0}"
    puts transaction
	end

	def send_items
		@json["items"].each do |item|
			transaction_item = {
				v: 1,
		    tid: @store.ga_un,
		    cid: @client_id || DEFAULT_CLIENT_ID, 
		    t: 'item',
		    ti: @json["code"],
		    in: item['product_name'],
		    ic: item["reference"],
				iv: item['variant_name'],
				ip: '%.2f' % (item["price"].to_f * @multiplier), 
				iq: item['quantity']
			}
			
			RestClient.get(ECOMMERCE_TRACKING_URL, params: transaction_item)

			puts "Item: #{@json["code"]} - #{item['reference']} - #{'%.2f' % (item["price"].to_f * @multiplier)} - #{item['quantity']} - #{item['product_name']} #{item['variant_name']}"
			puts transaction_item
		end		
	end

end