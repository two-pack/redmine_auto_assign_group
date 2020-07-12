require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineAutoAssignGroup
  class UsersTest < Redmine::IntegrationTest
    fixtures :email_addresses, :groups_users
    ActiveRecord::FixtureSet.create_fixtures(
      File.dirname(__FILE__) + '/../fixtures/', [:assign_rules, :users]
    )

    include RedmineAutoAssignGroup::IntegrationTestHelper

    def open_groups_tab
      Retryable.retryable(tries: 10) do
        within('div.tabs') do
          click_link('Groups')
        end
      end
    end

    def create_user_and_display_groups_tab(firstname, lastname, email)
      visit '/users'
      assert_visit

      click_link('New user')
      fill_in 'Login', with: @created_user_login
      fill_in 'First name', with: firstname
      fill_in 'Last name', with: lastname
      fill_in 'Email', with: email
      fill_in 'Password', with: 'password'
      fill_in 'Confirmation', with: 'password'
      click_button('Create')

      open_groups_tab
    end

    def delete_user
      visit '/users'
      assert_visit
      click_link(@created_user_login)
      page.accept_confirm 'Are you sure?' do
        click_link('Delete')
      end
    end

    def assert_find_checked_group(name)
      assert find('div#tab-content-groups').find('label', text: name).find('input').checked?
    end

    def assert_not_find_checked_group(name)
      assert_not find('div#tab-content-groups').find('label', text: name).find('input').checked?
    end

    def setup
      login_with_admin

      @created_user_login = ''
    end

    def teardown
      delete_user if @created_user_login.present?

      logout
    end

    def test_auto_assign_group_when_user_is_added_with_matching_all
      @created_user_login = 'test'
      create_user_and_display_groups_tab('Kaka', 'Uematsu', 'uematsu@zzz.example.com')

      assert_not_find_checked_group('A Team')
      assert_not_find_checked_group('B Team')
      assert_not_find_checked_group('C Team')
      assert_find_checked_group('D Team')
    end

    def test_not_auto_assign_group_when_user_is_added_without_matching_all
      @created_user_login = 'test'
      create_user_and_display_groups_tab('unused', 'unused', 'unused@unused.example.com')

      assert_not_find_checked_group('A Team')
      assert_not_find_checked_group('B Team')
      assert_not_find_checked_group('C Team')
      assert_not_find_checked_group('D Team')
    end

    def test_not_auto_assign_group_when_user_is_added_without_matching_firstname
      @created_user_login = 'test'
      create_user_and_display_groups_tab('Kata', 'Uematsu', 'uematsu@zzz.example.com')

      assert_not_find_checked_group('A Team')
      assert_not_find_checked_group('B Team')
      assert_not_find_checked_group('C Team')
      assert_not_find_checked_group('D Team')
    end

    def test_not_auto_assign_group_when_user_is_added_without_matching_lastname
      @created_user_login = 'test'
      create_user_and_display_groups_tab('Kaka', 'Uesugi', 'uematsu@zzz.example.com')

      assert_not_find_checked_group('A Team')
      assert_not_find_checked_group('B Team')
      assert_not_find_checked_group('C Team')
      assert_not_find_checked_group('D Team')
    end

    def test_not_auto_assign_group_when_user_is_added_without_matching_mail
      @created_user_login = 'test'
      create_user_and_display_groups_tab('Kaka', 'Uematsu', 'unused@unused.example.com')

      assert_not_find_checked_group('A Team')
      assert_not_find_checked_group('B Team')
      assert_not_find_checked_group('C Team')
      assert_not_find_checked_group('D Team')
    end

    def test_auto_assign_group_when_user_is_added_with_matching_mail
      @created_user_login = 'test'
      create_user_and_display_groups_tab('unused', 'unused', 'TakuyaSaito@abc.example.com')

      assert_not_find_checked_group('A Team')
      assert_find_checked_group('B Team')
      assert_not_find_checked_group('C Team')
      assert_not_find_checked_group('D Team')
    end

    def test_not_auto_assign_group_when_user_is_added_with_matching_mail
      @created_user_login = 'test'
      create_user_and_display_groups_tab('unused', 'unused', 'SaitoTatsuya@abc.example.co.jp')

      assert_not_find_checked_group('A Team')
      assert_not_find_checked_group('B Team')
      assert_not_find_checked_group('C Team')
      assert_not_find_checked_group('D Team')
    end

    def test_auto_assign_group_when_user_is_added_with_matching_firstname
      @created_user_login = 'test'
      create_user_and_display_groups_tab('Tatsuya', 'unused', 'unused@unused.example.com')

      assert_not_find_checked_group('A Team')
      assert_not_find_checked_group('B Team')
      assert_find_checked_group('C Team')
      assert_not_find_checked_group('D Team')
    end

    def test_not_auto_assign_group_when_user_is_added_with_matching_firstname
      @created_user_login = 'test'
      create_user_and_display_groups_tab('Katsuya', 'unused', 'unused@unused.example.com')

      assert_not_find_checked_group('A Team')
      assert_not_find_checked_group('B Team')
      assert_not_find_checked_group('C Team')
      assert_not_find_checked_group('D Team')
    end

    def test_auto_assign_group_when_user_is_added_with_matching_lastname
      @created_user_login = 'test'
      create_user_and_display_groups_tab('unused', 'Saito', 'unused@unused.example.com')

      assert_find_checked_group('A Team')
      assert_not_find_checked_group('B Team')
      assert_not_find_checked_group('C Team')
      assert_not_find_checked_group('D Team')
    end

    def test_not_auto_assign_group_when_user_is_added_with_matching_lastname
      @created_user_login = 'test'
      create_user_and_display_groups_tab('unused', 'Kato', 'unused@unused.example.com')

      assert_not_find_checked_group('A Team')
      assert_not_find_checked_group('B Team')
      assert_not_find_checked_group('C Team')
      assert_not_find_checked_group('D Team')
    end

    def test_do_not_assign_group_when_user_is_editted
      visit '/users'
      assert_visit

      click_link('jsmith')
      fill_in 'First name', with: 'James'
      find('#edit_user_2 > p > input[type=submit]').click

      open_groups_tab

      assert_not_find_checked_group('A Team')
      assert_not_find_checked_group('B Team')
      assert_not_find_checked_group('C Team')
      assert_not_find_checked_group('D Team')
    end
  end
end
