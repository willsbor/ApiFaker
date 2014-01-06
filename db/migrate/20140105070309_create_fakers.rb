class CreateFakers < ActiveRecord::Migration
  def change
    create_table :fakers do |t|
      t.string :api

      t.timestamps
    end

  end
end
