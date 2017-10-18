module RedmineAutoAssignGroup
  module GroupsHelperPatch
    def group_settings_tabs(group)
      tabs = super
      unless group.builtin?
        tabs << { name: 'rules', partial: 'groups/rules', label: :label_raag_rules }
      end
      tabs
    end
  end
end
