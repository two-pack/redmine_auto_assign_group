if (ENV['RAILS_ENV'] = 'test') && ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.coverage_dir('coverage/redmine_auto_assign_group')
  SimpleCov.start 'rails' do
    add_filter do |source_file|
      # report this plugin only.
      !source_file.filename.include?('plugins/redmine_auto_assign_group') ||
      !source_file.filename.end_with?('.rb')
    end
  end
end

Redmine::Plugin.register :redmine_auto_assign_group do
  name 'Redmine Auto Assign Group Plugin'
  author 'Tatsuya Saito'
  description 'This plugin automatically assigns group when user is added.'
  version '0.1.2'
  url 'https://github.com/two-pack/redmine_auto_assign_group'
  author_url 'mailto:twopackas@gmail.com'
  requires_redmine version_or_higher: '3.3'
end

ActiveRecord::CompatibleLegacyMigration.configure do |config|
  config.default_version = 4.2
end

if Rails.version > '6.0' && Rails.autoloaders.zeitwerk_enabled?
  unless GroupsHelper.included_modules.include?(RedmineAutoAssignGroup::GroupsHelperPatch)
    GroupsHelper.send(:prepend, RedmineAutoAssignGroup::GroupsHelperPatch)
  end

  unless User.included_modules.include? RedmineAutoAssignGroup::UserPatch
    User.send(:prepend, RedmineAutoAssignGroup::UserPatch)
  end

  unless Group.included_modules.include? RedmineAutoAssignGroup::GroupPatch
    Group.send(:prepend, RedmineAutoAssignGroup::GroupPatch)
  end
else
  Rails.configuration.to_prepare do
    unless GroupsHelper.included_modules.include?(RedmineAutoAssignGroup::GroupsHelperPatch)
      GroupsHelper.send(:prepend, RedmineAutoAssignGroup::GroupsHelperPatch)
    end

    unless User.included_modules.include? RedmineAutoAssignGroup::UserPatch
      User.send(:prepend, RedmineAutoAssignGroup::UserPatch)
    end

    unless Group.included_modules.include? RedmineAutoAssignGroup::GroupPatch
      Group.send(:prepend, RedmineAutoAssignGroup::GroupPatch)
    end
  end
end
