require 'hypothesis'
require 'test_helper'

class HypothesisTest < ActiveSupport::TestCase
  include Hypothesis
  include Hypothesis::Possibilities

  def stages
    any element_of([:inquiry, :lease_executed])
  end

  def deals(tenant:)
    built_as do
      existing_deal_count = any integers(min: 0, max: 3)
      existing_deal_count.times.map do
        Deal.create(tenant: tenant, stage: stages)
      end
    end
  end

  def new_deals(tenant:)
    built_as do
      Deal.create(tenant: tenant, stage: stages)
    end
  end
  
  def test_hypo2
    hypothesis do
      DatabaseCleaner.clean

      tenant_count = any integers(min: 2, max: 4), name: 'Tenant Count'
      tenant_count.times do |i|
        Tenant.create(name: "Tenant #{i}")
      end

      tenant = Tenant.first
      deals_matching_criteria = any deals(tenant: tenant), name: 'Connected Deals'
      other_deals = any deals(tenant: any(element_of(Tenant.all - [tenant]))), name: 'Existing Deals'
      
      new_deal = any new_deals(tenant: tenant), name: 'New Deal'

      if Connections.connection_exists?(new_deal)
        any_late_stage_deal = deals_matching_criteria.any? { |d| d.stage.to_sym == :lease_executed }
        assert_equal true, any_late_stage_deal
      else
        assert_equal true, deals_matching_criteria.all? { |d| d.stage.to_sym == :inquiry }
      end
    end    
  end
end