module Connections
  def self.connection_exists?(deal)
    Deal.where(tenant: deal.tenant, stage: :lease_executed).where.not(id: deal.id).count > 0
  end

  def self.connection_exists_bug?(deal)
    Deal.where(tenant: deal.tenant, stage: :lease_executed).count > 1
  end

  def self.connection_exists_r?(deal, repo)
    repo.deals.count > 0
  end
end