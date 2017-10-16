require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

if ((Redmine::VERSION::MAJOR == 3) && (Redmine::VERSION::MINOR >= 4)) ||
   (Redmine::VERSION::MAJOR >= 4)
  require File.expand_path(File.dirname(__FILE__) + '/users_test_latest')
else
  require File.expand_path(File.dirname(__FILE__) + '/users_test_33x')
end
