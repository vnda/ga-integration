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

  test 'product-listed' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(il1nm: 'Produtos relacionados', il1pi1ps: '1', il1pi2ps: '2', il1pi3ps: '3'))
    json = {
      'list' => 'Produtos relacionados',
      'resource' => [
        { 'reference' => 'P1', 'name' => 'Cueca', 'price' => 15.0, 'position' => 1 },
        { 'reference' => 'P2', 'name' => 'Meia', 'price' => 12.0, 'position' => 2 },
        { 'reference' => 'P3', 'name' => 'Cinto', 'price' => 78.0, 'position' => 3 }
      ]
    }
    it = UniversalAnalyticsEventSender.new(json, store, 'product-listed')
    it.send!
    assert_requested(stub)
  end
end
