require 'test_helper'

class EventSenderTest < ActiveSupport::TestCase
  def store; stores(:one) end

  test 'product-viewed event' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(t: 'event', pa: 'detail'))
    json = {
      'reference' => 'RT001',
      'name' => 'Cueca para Incontinência Urinária',
      'price' => 159.0
    }
    it = UniversalAnalyticsEventSender.new(json, store, 'product-viewed')
    it.send!
    assert_requested(stub)
  end

  test 'product-added-to-cart event' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(t: 'event', pa: 'add'))
    json = {
      'reference' => 'RT001',
      'name' => 'Cueca para Incontinência Urinária',
      'price' => 159.0,
      'variant_name' => 'Tamanho: PP | Cor: Branca',
      'quantity' => 2
    }
    it = UniversalAnalyticsEventSender.new(json, store, 'product-added-to-cart')
    it.send!
    assert_requested(stub)
  end
end
