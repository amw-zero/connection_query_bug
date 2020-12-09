class Deal < ApplicationRecord
  enum stage: [:inquiry, :lease_executed]
  
  belongs_to :tenant

  validates :stage, presence: true
end