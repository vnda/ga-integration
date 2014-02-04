class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name
      t.string :ga
      t.string :token
      t.string :site

      t.timestamps
    end
  end
end
