require_dependency 'user'
require_dependency 'assign_rule'

module RedmineAutoAssignGroup
  module UserPatch

    def save(*args, &block)
      return super unless new_record?

      new_user = super
      return new_user unless new_user

      begin
        AssignRule.match_groups(self).each do |group|
          group.users << self unless group.users.exists?(:id => id)
        end
      rescue Exception => e
        # Treat is as succeed even if group assigning is failed.
        logger.error "redmine_auto_assign_group: error during assign group: #{e.message}"
      end

      new_user
    end

  end
end