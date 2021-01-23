require 'hypothesis'
require 'test_helper'

# predicates on complete graphs to define data model?

class HypothesisTest < ActiveSupport::TestCase
  include Hypothesis
  include Hypothesis::Possibilities

  def debug(all_deals, new_deal)
    puts "All deals"
    puts all_deals.to_s

    puts; puts "New deal"
    puts new_deal.inspect
    puts "================="
    puts
  end

  def stages
    any element_of([:inquiry, :lease_executed])
  end

  def gen_deals(for_tenants:)
    array(of: gen_deal(for_tenants: for_tenants), min_size: 1, max_size: 5)
  end
  
  def gen_deal(for_tenants:)
    built_as do
      Deal.create(tenant: any(element_of(for_tenants)), stage: stages)
    end
  end

  def gen_tenant
    built_as { Tenant.create(name: any(string)) }
  end

  def tenants
    array(of: gen_tenant, min_size: 2, max_size: 4)
  end  

  def test_deal_connection_query
    x = 0
    hypothesis(max_valid_test_cases: 25) do
      puts "Iteration #{x}"
      x += 1
      DatabaseCleaner.clean

      all_tenants = any tenants, name: 'All Tenants'
      all_deals = any gen_deals(for_tenants: all_tenants), name: 'All Deals'
      new_deal = any element_of(all_deals), name: 'New Deal'

      deals = Deal.all - [new_deal]
      is_connected = deals.any? do |deal|
        deal.tenant == new_deal.tenant && deal.stage.to_sym == :lease_executed
      end

      assert_equal is_connected, Connections.connection_exists_bug?(new_deal)
    end
  end
end