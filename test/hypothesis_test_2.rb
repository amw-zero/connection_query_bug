require 'hypothesis'
require 'test_helper'

class HypothesisTest < ActiveSupport::TestCase
  include Hypothesis
  include Hypothesis::Possibilities

  def stages
    any element_of([:inquiry, :lease_executed])
  end

  def deals(for_tenants:)
    built_as do
      existing_deal_count = any integers(min: 2, max: 5)
      existing_deal_count.times.map do |i|
        tenant = any element_of(for_tenants)
        Deal.create(tenant: tenant, stage: stages)
      end
    end
  end

  def tenants
    built_as do
      tenant_count = any integers(min: 2, max: 4), name: 'Tenant Count'
      tenant_count.times.map do |i|
        Tenant.create(name: "Tenant #{i}")
      end
    end
  end

  def debug(all_deals, new_deal)
    puts "All deals"
    puts all_deals.to_s

    puts; puts "New deal"
    puts new_deal.inspect
    puts "================="
    puts
  end

  def test_deal_connection_query
    hypothesis do
      DatabaseCleaner.clean

      all_tenants = any tenants, name: 'All Tenants'
      all_deals = any deals(for_tenants: all_tenants), name: 'All Deals'
      new_deal = any element_of(all_deals), name: 'New Deal'

      deals = Deal.all - [new_deal]
      is_connected = deals.any? do |deal|
        deal.tenant == new_deal.tenant && deal.stage.to_sym == :lease_executed
      end

      assert_equal is_connected, Connections.connection_exists?(new_deal)
    end
  end
end