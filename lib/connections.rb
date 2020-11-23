module Connections
  def self.connection_exists?(deal)
    tenant = deal.tenant

    Deal.where(tenant: tenant, stage: :loi).count > 0
  end
end