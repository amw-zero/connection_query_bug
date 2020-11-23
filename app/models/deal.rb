class Deal < ApplicationRecord
  enum stage: [:inquiry, :loi]
  
  belongs_to :tenant

  validates :stage, presence: true
end