require 'test_helper'

class GaEcommerceTest < ActiveSupport::TestCase
  def store; stores(:one) end

  def data
    {
      'reference' => 'RT001',
      'name' => 'Cueca para Incontinência Urinária',
      'price' => 159.0,
      'variant_name' => 'Tamanho: PP | Cor: Branca',
      'quantity' => 2
    }
  end

  test 'product-viewed event' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(t: 'event', pa: 'detail'))
    res = data.slice('reference', 'name', 'price')
    it = UniversalAnalyticsEventSender.new({ 'resource' => res }, store, 'product-viewed')
    it.send!
    assert_requested(stub)
  end

  test 'product-added-to-cart event' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(t: 'event', pa: 'add'))
    it = UniversalAnalyticsEventSender.new({ 'resource' => data }, store, 'product-added-to-cart')
    it.send!
    assert_requested(stub)
  end

  test 'product-removed-from-cart' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(t: 'event', pa: 'remove'))
    it = UniversalAnalyticsEventSender.new({ 'resource' => data }, store, 'product-removed-from-cart')
    it.send!
    assert_requested(stub)
  end
end
