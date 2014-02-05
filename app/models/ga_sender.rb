	class GaSender

		def initialize(json, store)
			@json = json
			@store = store
			@sender = Gabba::Gabba.new(@store.ga, @store.site)
			@multiplier = json['status'] == 'confirmed' ? 1 : -1
		end

	  def send!
	  	send_itens
	  	send_transaction

	  	puts "Transaction has been sent!"
	  end

	  private

	  def send_itens
	  	order_id = @json["code"]
	  	@json["items"].each do |item|
	  		puts "Item: #{order_id} - #{item["reference"]} - #{item["price"].to_i * @multiplier} - #{item['quantity']} - #{item['product_name']} #{item['variant_name']}"
	  		@sender.add_item(order_id, 
	  			item["reference"], 
	  			item["price"].to_i * @multiplier, 
	  			item['quantity'], 
	  			item['product_name'], item['variant_name'])
	  	end 
	  end

	  def send_transaction
	  	address = "#{@json['street_name']}, #{@json['complement']} - #{@json['zip']}"
	  	puts "Transaction: #{@json["code"]}, #{@json['total'].to_i * @multiplier}, #{@store.name}, #{0.0}, #{address}, #{@json['city']}, #{@json['state']}, #{'Brasil'}"
	  	@sender.transaction(@json["code"], @json['total'].to_i * @multiplier, @json['email'], 
	  		0.0, @json['shipping_price'], "#{@json['city']} - #{@json['state']}", address, "Brasil")
	  end

	end
