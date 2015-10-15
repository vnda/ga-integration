class StoresController < ApplicationController
  before_filter :authenticate!
  protect_from_forgery except: [:create]

  def index
  end

  def new
  end

  def edit
  end

  #curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" --user vnda:xxxxxxxx http://localhost:3000/stores
  def create
    respond_to do |format|
      if resource.save
        format.html { redirect_to stores_path, notice: I18n.t(:create, scope: [:flashes, :store]) }
        format.json { render json: resource.token, status: 201 }
      else
        format.html { render action: 'new' }
        format.json { render json: resource }
      end
    end
  end

  def update
    respond_to do |format|
      if resource.update(store_params)
        format.html { redirect_to stores_path, notice: I18n.t(:update, scope: [:flashes, :store]) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    resource.destroy
    respond_to do |format|
      format.html { redirect_to stores_path, notice: I18n.t(:destroy, scope: [:flashes, :store]) }
    end
  end

  private

  def collection
    @collection ||= Store.order(:name)
  end

  def resource
    @resource ||= params[:id] ? Store.find(params[:id]) : Store.new(store_params)
  end

  def store_params
    params[:store].try(:permit, :name, :ga, :ga_un, :token, :site)
  end
end
