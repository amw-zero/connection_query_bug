require 'test_helper'

class PropertyTest < TestCase
  include PropCheck::Generators

  def generate_stage
    one_of(constant(:inquiry), constant(:lease_executed))
  end

  def two_stages
    tuple(generate_stage, generate_stage)
  end

  def test_somethin
    PropCheck.forall(
      existing_stage: generate_stage,
      new_stage: generate_stage,
    ) do |existing_stage:, new_stage:|
      tenant = Tenant.create(name: 't1')
      existing_deal = Deal.create(tenant: tenant, stage: existing_stage)
      new_deal = Deal.create(tenant: tenant, stage: new_stage)

      # An existing connection implies that the existing deals have at lease one stage of lease_executed,
      # and a non-existing connection implies that all existing deals has a stage of :inquiry
      if Connections.connection_exists?(new_deal)
        assert_equal :lease_executed, existing_stage
      else
        assert_equal :inquiry, existing_stage
      end

      DatabaseCleaner.clean
    end
  end

  def test_somethin_else
    PropCheck.forall(
      existing_stage: generate_stage,
      new_stage: generate_stage,
    ) do |existing_stage:, new_stage:|
      tenant = Tenant.create(name: 't1')
      existing_deal = Deal.create(tenant: tenant, stage: existing_stage)
      new_deal = Deal.create(tenant: tenant, stage: new_stage)

      # An existing connection implies that the existing deals have at lease one stage of lease_executed,
      # and a non-existing connection implies that all existing deals has a stage of :inquiry
      if Connections.connection_exists?(new_deal)
        assert_equal :lease_executed, existing_stage
      else
        assert_equal :inquiry, existing_stage
      end

      DatabaseCleaner.clean
    end
  end

  # def test_tuple
  #   PropCheck.forall(
  #     stages: two_stages
  #   ) do |stages:|
  #     puts stages.to_s
  #   end
  # end
end
