class CreateDealsAndTenants < ActiveRecord::Migration[5.2]
  # Tenant
# Deal -> Tenant | stage
  def change
    create_table :tenants do |t|
      t.string :name
    end

    create_table :deals do |t|
      t.integer :stage
      t.references :tenant
    end
  end
end
