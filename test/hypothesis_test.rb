require 'hypothesis'
require 'test_helper'

class HypothesisTest < ActiveSupport::TestCase
  include Hypothesis
  include Hypothesis::Possibilities
  
  def test_hypo2
    hypothesis do
      puts "========"
      puts "  Frame"
      puts "========="
      DatabaseCleaner.clean
      puts "Starting Deal count: #{Deal.count}"

      tenant_count = any integers(min: 2, max: 4), name: 'Tenant Count'
      tenant_count.times do |i|
        Tenant.create(name: "Tenant #{i}")
      end

      existing_deals = any(
        built_as do
          existing_deal_count = any integers(min: 0, max: 1)
          existing_deal_count.times.map do
            Deal.create(tenant: any(element_of(Tenant.all)), stage: any(element_of([:inquiry, :lease_executed])))
          end
        end,
        name: 'Existing Deals'
      )
      
      new_deal = any(
        built_as do
          Deal.create(tenant: Tenant.first, stage: any(element_of([:inquiry, :lease_executed])))
        end, 
        name: 'New Deal'
      )

      puts; puts

      if Connections.connection_exists_bug?(new_deal)
        puts "Hello "
        puts existing_deals.to_s
        puts existing_deals.any? { |d| d.stage.to_sym == :lease_executed }
        any_late_stage_deal = existing_deals.any? { |d| d.stage.to_sym == :lease_executed }
        assert_equal true, any_late_stage_deal
      else
        assert_equal true, existing_deals.all? { |d| d.stage.to_sym == :inquiry } || existing_deals.empty?
      end
      
    end    
  end
end