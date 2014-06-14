require 'test_helper'

class EventSenderTest < ActiveSupport::TestCase
  test 'product-viewed event' do
    VCR.use_cassette('product-viewed') do
      store = stores(:one)
      json = {
        'reference' => 'RT001',
        'name' => 'Cueca para Incontinência Urinária',
        'price' => 159.0
      }
      it = UniversalAnalyticsEventSender.new(json, store, 'product-viewed')
      it.send!
    end
  end

  test 'product-added-to-cart event' do
    VCR.use_cassette('product-added-to-cart') do
      store = stores(:one)
      json = {
        'reference' => 'RT001',
        'name' => 'Cueca para Incontinência Urinária',
        'price' => 159.0,
        'variant_name' => 'Tamanho: PP | Cor: Branca',
        'quantity' => 2
      }
      it = UniversalAnalyticsEventSender.new(json, store, 'product-added-to-cart')
      it.send!
    end
  end
end
