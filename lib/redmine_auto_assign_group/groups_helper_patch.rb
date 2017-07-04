require_dependency 'groups_helper'
require_dependency 'redmine_auto_assign_group/reloader'

module RedmineAutoAssignGroup
  module GroupsHelperPatch
    def group_settings_tabs(group)
      tabs = super
      tabs << {:name => 'rules', :partial => 'groups/rules', :label => :label_raag_rules}
      tabs
    end

    def get_group_rules(group)
      AssignRule.where(:group_id => group.id).order(:position => :asc)
    end
  end

  Reloader.to_prepare do
    unless GroupsHelper.included_modules.include?(RedmineAutoAssignGroup::GroupsHelperPatch)
      GroupsHelper.send(:prepend, RedmineAutoAssignGroup::GroupsHelperPatch)
    end
  end
end