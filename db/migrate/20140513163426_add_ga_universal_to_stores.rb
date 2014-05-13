class AddGaUniversalToStores < ActiveRecord::Migration
  def change
  	add_column :stores, :ga_un, :string
  end
end
