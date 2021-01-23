class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def inspect_associations
    self.class.reflect_on_all_associations.map do |a|
      value = self.public_send(a.name)
      { a.name.to_sym => value.id }
    end
  end

  def foreign_keys
    self.class.reflect_on_all_associations.map(&:foreign_key).compact
  end

  def inspect
    str = "<#{self.class} #{id}: #{attributes.except('id', *foreign_keys)}"
    assocs = inspect_associations
    str << " | Associations: #{inspect_associations}>" unless assocs.empty?

    str
  end
end
