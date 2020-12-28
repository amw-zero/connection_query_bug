require 'hypothesis'
require 'test_helper'

module Specify
  class Set
    class Type
      def initialize(value)
        @value = value
      end
    end

    attr_reader :name

    def initialize(name:, value: nil, schema: nil)
      @name = name
      @value = value
      @schema = @schema
    end
  end

  class Relation
    attr_reader :name, :signature

    def initialize(name:, signature:, &blk)
      @name = name
      @signature = signature
      @body = blk
    end

    def apply(*args)
      @body.call(*args)
    end
  end

  class TestCase
    attr_reader :expected, :actual

    def initialize(expected:, actual:)
      @expected = expected
      @actual = actual
    end
  end

  class Specification
    include Hypothesis
    include Hypothesis::Possibilities

    def initialize(definitions)
      @definitions = definitions
      @definition_index = definitions.group_by(&:name)
    end

    def create_spec_value(type)
      puts "Create value for #{type}"

      5
    end

    def create_implementation_value(type)
      puts "Create value for #{type}"

      5
    end

    def verify(names, implementations:)
      to_verify = if names.empty?
                    @definitions.select { |definition| definition.is_a?(Relation) }
                  else
                    @definitions.select { |definition| names.include?(definition.name) }
                  end

      to_verify.each do |definition|
        puts "Going to verify: #{definition.name}"

        hypothesis do 
          spec_inputs = definition.signature.map { |type| create_spec_value(type) }
          expected = definition.apply(*spec_inputs)

          actual_inputs = definition.signature.map { |type| create_implementation_value(type) }
          actual = implementations[definition.name].call(*actual_inputs)

          yield(TestCase.new(expected: expected, actual: actual))
        end
      end
    end
  end
end

class SpecificationTest < ActiveSupport::TestCase
  # def test_specification
  #   spec = Specify::Specification.new([
  #     Specify::Set(name: :deal_stage, value: [:inquiry, :lease_executed]),

  #     Specify::Set(name: :tenant, schema: [{ name: :string }]),

  #     Specify::Set(name: :deal, schema: [{ tenant: :tenant }, { stage: :deal_stage }]),

  #     Specify::Set(name: :deal_pipeline, schema: [{ deals: Specify::Set::Type(:deal) }]),

  #     Specify::Relation(name: :deal_connection_exists, signature: [:deal, :deal_pipeline]) do |deal, deals|
  #       deals.any? { |deal, all_deals| deal.tenant == tenant && deal.stage == lease }
  #     end
  #   ])

  #   spec.verify(:deal_connection_exists) do |test_case|
  #     assert_equal test_case.expected, test_case.actual
  #   end
  # end

  def test_simple
    add = Specify::Relation.new(name: :add, signature: [:number, :number]) do |n1, n2|
      n1 + n2
    end
    spec = Specify::Specification.new([
      Specify::Set.new(name: :number, value: [1, 2, 3]),

      add
    ])

    def add_impl(n1, n2)
      n1 - n2
    end

    implementations = { add: -> (n1, n2) { add_impl(n1, n2) } }

    spec.verify([:add], implementations: implementations) do |test_case|
      assert_equal test_case.expected, test_case.actual
    end
  end
end