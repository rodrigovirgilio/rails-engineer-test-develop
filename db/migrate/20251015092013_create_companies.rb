class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :coc_number, null: false
      t.string :city, null: false
      t.text :address

      t.timestamps
    end

    add_index :companies, :coc_number, unique: true

    add_index :companies, :name
    add_index :companies, :city

    add_index :companies, [:name, :city]
  end
end
