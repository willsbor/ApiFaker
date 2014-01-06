class CreateApiPrototypes < ActiveRecord::Migration
  def change
    create_table :api_prototypes do |t|
      t.integer :faker_id
      t.text :prototype

      t.timestamps
    end

    add_index :api_prototypes, :faker_id
  end
end
