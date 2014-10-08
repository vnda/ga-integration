require 'test_helper'

class GaEcommerceTest < ActiveSupport::TestCase
  def setup
    WebMock.reset!
  end

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

  def checkout_data
    [
      { 'reference' => 'P1', 'name' => 'Cueca', 'price' => 15.0, 'quantity' => 2 },
      { 'reference' => 'P2', 'name' => 'Meia', 'price' => 12.0, 'quantity' => 3 },
      { 'reference' => 'P3', 'name' => 'Cinto', 'price' => 78.0, 'quantity' => 1 }
    ]
  end

  test 'checkout-1-cart' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(pa: 'checkout', cos: '1', pr1pr: '15.0', pr2pr: '12.0', pr3pr: '78.0'))
    UniversalAnalyticsEventSender.new({ 'resource' => checkout_data }, store, 'checkout-1-cart').send!
    assert_requested(stub)
  end

  test 'checkout-2-shipping-calc' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(pa: 'checkout', cos: '2', col: 'Rio de Janeiro'))
    json = { 'city_name' => 'Rio de Janeiro', 'resource' => checkout_data }
    UniversalAnalyticsEventSender.new(json, store, 'checkout-2-shipping-calc').send!
    assert_requested(stub)
  end

  test 'checkout-3-shipping-mode' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(pa: 'checkout', cos: '3', col: 'airplane'))
    json = { 'shipping' => 'airplane', 'resource' => checkout_data }
    UniversalAnalyticsEventSender.new(json, store, 'checkout-3-shipping-mode').send!
    assert_requested(stub)
  end

  test 'checkout-4-address' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(pa: 'checkout', cos: '4'))
    UniversalAnalyticsEventSender.new({ 'resource' => checkout_data }, store, 'checkout-4-address').send!
    assert_requested(stub)
  end

  test 'checkout-5-payment' do
        stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(pa: 'checkout', cos: '5', col: 'Visa'))
    json = { 'payment' => 'Visa', 'resource' => checkout_data }
    UniversalAnalyticsEventSender.new(json, store, 'checkout-5-payment').send!
    assert_requested(stub)
  end

  test 'get cid from analytics param' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(cid: '252941435.1407291507'))
    json = { 'analytics' => { '_ga'=>'GA1.3.252941435.1407291507' }, 'resource' => data }
    UniversalAnalyticsEventSender.new(json, store, 'product-viewed').send!
    assert_requested(stub)
  end

  test 'get cid from extra fields' do
    stub = stub_request(:get, 'www.google-analytics.com/collect')
      .with(query: hash_including(cid: '252941435.1407291507'))
    json = {
      'extra_fields' => [
        { 'name' => '_ga', 'value' => 'GA1.3.252941435.1407291507' }
      ],
      'resource' => data
    }
    UniversalAnalyticsEventSender.new(json, store, 'product-viewed').send!
    assert_requested(stub)
  end
end
