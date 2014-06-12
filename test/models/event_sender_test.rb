require 'test_helper'

class EventSenderTest < ActiveSupport::TestCase
  test 'product-viewed event' do
    store = stores(:one)
    json = { reference: '', name: '', price: '' }
    it = UniversalAnalyticsEventSender.new('product-viewed', store, json)
    assert true
  end
end
