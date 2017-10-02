Redmine::Plugin.register :redmine_auto_assign_group do
  name 'Redmine Auto Assign Group Plugin'
  author 'Tatsuya Saito'
  description 'This plugin automatically assigns group when user is added.'
  version '0.0.1'
  url 'https://github.com/two-pack/redmine_auto_assign_group'
  author_url 'mailto:twopackas@gmail.com'
  requires_redmine :version_or_higher => '3.3'
end

require_dependency 'redmine_auto_assign_group/groups_helper_patch'

ActiveRecord::CompatibleLegacyMigration.configure do |config|
  config.default_version = 4.2
end

Rails.configuration.to_prepare do
  require_dependency 'user'
  require_dependency 'group'

  unless User.included_modules.include? RedmineAutoAssignGroup::UserPatch
    User.send(:prepend, RedmineAutoAssignGroup::UserPatch)
  end

  unless Group.included_modules.include? RedmineAutoAssignGroup::GroupPatch
    Group.send(:prepend, RedmineAutoAssignGroup::GroupPatch)
  end
end