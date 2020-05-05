class GaSender
  def initialize(json, store)
    @json = json
    @store = store
    @sender = Gabba::Gabba.new(@store.ga, @store.site)
    @multiplier = json['status'] == 'canceled' ? -1 : 1
  end

  def send!
    return if(@json['status'] == 'confirmed')
    send_utmcc
    send_itens
    send_transaction

    puts "Transaction has been sent!"
  end

  private

  def send_utmcc
    utma, utmz = nil
    @json['extra_fields'].each do |field|
      utma = field['value'] if field['name'] == '__utma'
      utmz = field['value'] if field['name'] == '__utmz'
    end
    if utma && utmz
      puts "utmcc: __utma => #{utma}, __utmz => #{utmz}"
      @sender.utmcc = "__utma=#{utma};+__utmz=#{utmz};"
    else
      puts "utmcc not present"
    end
  end

  def send_itens
    order_id = @json["code"]
    @json["items"].each do |item|
      puts "Item: #{order_id} - #{item['reference']} - #{'%.2f' % (item["price"].to_f * @multiplier)} - #{item['quantity']} - #{item['product_name']} #{item['variant_name']}"
      @sender.add_item(
        order_id,
        item["reference"],
        '%.2f' % (item["price"].to_f * @multiplier),
        item['quantity'],
        item['product_name'], item['variant_name']
      )
    end
  end

  def send_transaction
    address = "#{@json['street_name']}, #{@json['complement']} - #{@json['zip']}"
    puts "Transaction: #{@json["code"]}, #{'%.2f' % (@json['total'].to_f * @multiplier)}, #{@store.name}, #{0.0}, #{address}, #{@json['city']}, #{@json['state']}, #{'Brasil'}"
    @sender.transaction(
      @json["code"],
      '%.2f' % (@json['total'].to_f * @multiplier),
      @json['agent'],
      0.0,
      @json['shipping_price'],
      "#{@json['city']} - #{@json['state']}",
      address,
      "Brasil"
    )
  end
end
