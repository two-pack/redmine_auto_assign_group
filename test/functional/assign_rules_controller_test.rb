require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

if (Redmine::VERSION::MAJOR >= 4) || (Redmine::VERSION::BRANCH == 'devel')
  require File.expand_path(File.dirname(__FILE__) + '/assign_rules_controller_test_latest')
else
  require File.expand_path(File.dirname(__FILE__) + '/assign_rules_controller_test_3xx')
end
