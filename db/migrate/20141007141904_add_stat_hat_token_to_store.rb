class AddStatHatTokenToStore < ActiveRecord::Migration
  def change
    add_column :stores, :stat_hat_token, :string
  end
end
