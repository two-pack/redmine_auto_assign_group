require_dependency 'group'
require_dependency 'assign_rule'

module RedmineAutoAssignGroup
  module GroupPatch
    Group.module_eval do
      has_many :assign_rule, dependent: :destroy
    end
  end
end
