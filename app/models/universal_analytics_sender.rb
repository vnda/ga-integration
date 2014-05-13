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
		@cid = @json['extra_fields'].select{|field| field['name'] == 'cid'}.first
    puts "cid not present" unless @cid
	end

	def send_transaction
		puts "Transaction: #{@json["code"]}, #{'%.2f' % (@json['total'].to_f * @multiplier)}, #{@store.name}, #{0.0}"
		RestClient.get(ECOMMERCE_TRACKING_URL, params: {
	      v: 1,
	      tid: @store.ga,
	      cid: @cid || DEFAULT_CLIENT_ID, 
	      t: 'transaction',
	      ti: @json["code"],
	      ta: @json['email'],
	      tr: '%.2f' % (@json['total'].to_f * @multiplier), 
	      tt: 0.0,
	      ts: @json['shipping_price']
	    }
		)
	end

	def send_items
		@json["items"].each do |item|
			puts "Item: #{@json["code"]} - #{item['reference']} - #{'%.2f' % (item["price"].to_f * @multiplier)} - #{item['quantity']} - #{item['product_name']} #{item['variant_name']}"
			RestClient.get(ECOMMERCE_TRACKING_URL, params: {
					v: 1,
			    tid: @store.ga,
			    cid: @cid || DEFAULT_CLIENT_ID, 
			    t: 'item',
			    ti: @json["code"],
			    in: item['product_name'],
			    ic: item["reference"],
					iv: item['variant_name'],
					ip: '%.2f' % (item["price"].to_f * @multiplier), 
					iq: item['quantity']
				}
			)
		end		
	end

end