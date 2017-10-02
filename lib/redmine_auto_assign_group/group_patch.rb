require_dependency 'group'
require_dependency 'assign_rule'

module RedmineAutoAssignGroup
  module GroupPatch
    Group.module_eval do
      has_many :assign_rules, -> { order(:position => :asc) }, dependent: :destroy
    end
  end
end
