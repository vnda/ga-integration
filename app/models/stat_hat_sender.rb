class StatHatSender
  # Example for this sender
  #HooksService.run("order_confirmed").with({stat_name: 'order confirmed', stat_value: 1, event_type: 'count'})

  def initialize(json, store)
    @stat_name = json['stat_name']
    @stat_hat_token = store.stat_hat_token
    @stat_value = json['stat_value']
    @event_type = json['event_type']
  end

  def send!
    case @event_type
    when 'value' then StatHat::API.ez_post_value(@stat_name, @stat_hat_token, @stat_value)
    when 'count' then StatHat::API.ez_post_count(@stat_name, @stat_hat_token, @stat_value)
    end
    Rails.logger.debug("Stathat Event sent: #{@stat_name}")
  end

end
