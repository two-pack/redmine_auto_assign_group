require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineAutoAssignGroup
  class UsersTest < Redmine::IntegrationTest
    fixtures :users, :groups_users

    ActiveRecord::FixtureSet.create_fixtures(
      File.dirname(__FILE__) + '/../fixtures/', [:assign_rules]
    )

    include RedmineAutoAssignGroup::IntegrationTestHelper

    def setup
      page.driver.headers = { 'Accept-Language' => 'en-US' }

      login_with_admin
    end

    def teardown
      logout
    end

    def test_auto_assign_group_when_user_is_added
      visit '/users'
      assert_not_nil page

      click_link('New user')
      fill_in 'Login', with: 'saito'
      fill_in 'First name', with: 'Tatsuya'
      fill_in 'Last name', with: 'Saito'
      fill_in 'Email', with: 'saito@abc.example.com'
      fill_in 'Password', with: 'password'
      fill_in 'Confirmation', with: 'password'
      click_button('Create')

      within('div.tabs') do
        click_link('Groups')
      end

      short_wait_time do
        assert_not find('div#tab-content-groups').find('label', text: 'A Team').find('input').checked?
      end
      assert find('div#tab-content-groups').find('label', text: 'B Team').find('input').checked?
    end

    def test_do_not_assign_group_when_user_is_editted
      visit '/users'
      assert_not_nil page

      click_link('jsmith')
      fill_in 'First name', with: 'James'
      click_button('Save')

      within('div.tabs') do
        click_link('Groups')
      end

      assert_not find('div#tab-content-groups').find('label', text: 'A Team').find('input').checked?
      assert_not find('div#tab-content-groups').find('label', text: 'B Team').find('input').checked?
    end
  end
end
