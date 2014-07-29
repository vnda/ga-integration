class MetricsController < ApplicationController
  def show
    store = Store.find(params[:store_id])
    vid = GaReport.view_id_for_property(store.ga_un)
    if vid.blank?
      msg = "Current service account has no access to this property: #{GaReport.service_account_email}"
      return render status: :forbidden, json: { error: msg }
    end

    data = GaReport.report(view_id: vid, sku: params[:id])
    if data.rows.empty?
      return head :not_found
    end

    render json: build_json(data)
  end

  private

  def build_json(ga_data)
    headers = ga_data.column_headers.map(&:name)
    hash = headers.zip(ga_data.rows.first).to_h

    {
      reference:         hash['ga:productSku'],
      detail_views:      hash['ga:productDetailViews'].to_i,
      list_views:        hash['ga:productListViews'].to_i,
      adds_to_cart:      hash['ga:productAddsToCart'].to_i,
      removes_from_cart: hash['ga:productRemovesFromCart'].to_i,
    }
  end
end
