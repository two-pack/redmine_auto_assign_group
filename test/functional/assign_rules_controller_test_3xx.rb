require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class AssignRulesControllerTest < ActionController::TestCase
  fixtures :groups_users
  ActiveRecord::FixtureSet.create_fixtures(
      File.dirname(__FILE__) + '/../fixtures/', [:users, :assign_rules]
  )

  def setup
    User.current = nil
    @request.session[:user_id] = 1 # admin
  end

  def test_destroy
    assert_difference 'AssignRule.count', -1 do
      delete :destroy, id: 1, group_id: 11
    end

    assert_redirected_to controller: 'groups', action: 'edit', id: 11, tab: :rules
    assert_nil AssignRule.find_by_id(1)
  end

  def test_destroy_with_invalid_id
    flash[:error] = ''

    assert_no_difference 'AssignRule.count' do
      delete :destroy, id: -1, group_id: 11
    end

    assert_redirected_to controller: 'groups', action: 'edit', id: 11, tab: :rules
    assert_equal 'Unable to delete rule', flash[:error]
  end
end
