require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineAutoAssignGroup
  class GroupsRulesTabTest < Redmine::IntegrationTest
    fixtures :users, :groups_users

    ActiveRecord::FixtureSet.create_fixtures(
      File.dirname(__FILE__) + '/../fixtures/', [:assign_rules]
    )

    include RedmineAutoAssignGroup::IntegrationTestHelper

    def setup
      page.driver.headers = { 'Accept-Language' => 'en-US' }

      login_with_admin

      visit '/groups'
      assert_not_nil page
    end

    def teardown
      logout
    end

    def test_show_rules_tab
      find('tr#group-10 td.name a').click
      assert page.find('a#tab-rules')
    end

    def test_not_to_show_rules_tab_with_non_member
      find('tr#group-12 td.name a').click

      short_wait_time do
        assert_raise Capybara::ElementNotFound do
          find('a#tab-rules')
        end
      end
    end

    def test_not_to_show_rules_tab_with_anonymous
      find('tr#group-13 td.name a').click

      short_wait_time do
        assert_raise Capybara::ElementNotFound do
          find('a#tab-rules')
        end
      end
    end

    def test_cannot_show_rules_tab_without_admin
      logout
      login_with_user

      visit 'groups/10/edit?tab=rules'
      assert_equal 403, page.status_code
    end

    def test_do_not_show_rules_when_no_rules
      click_link('A Team')
      find('a#tab-rules').click

      assert find('p.nodata', text: 'No data to display')
    end

    def test_show_rules
      click_link('B Team')
      find('a#tab-rules').click

      within(:css, 'tr#rule-1') do
        assert find('td.name', text: 'ABC Example')
        assert find('td.rule', text: '.+@abc.example.com')
      end

      within(:css, 'tr#rule-2') do
        assert find('td.name', text: 'XYZ Corp')
        assert find('td.rule', text: '.+@xyz.corp.co.jp')
      end

      within(:css, 'tr#rule-3') do
        assert find('td.name', text: 'PQR Inc.')
        assert find('td.rule', text: '.+@pqr.net')
      end
    end

    def test_create_new_rule
      click_link('B Team')
      find('a#tab-rules').click
      click_link('New rule')

      fill_in 'Name', with: 'New Tech Company A'
      fill_in 'Rule', with: '.+@a.new-tech.com'
      click_button('Create')

      assert find('div#flash_notice', text: 'Successful creation.')
      assert_equal '/groups/11/edit', current_path
      assert find('td.name', text: 'New Tech Company A')
      assert find('td.rule', text: '.+@a.new-tech.com')
    end

    def test_fail_to_create_new_rule_with_invalid_regexp
      click_link('B Team')
      find('a#tab-rules').click
      click_link('New rule')

      fill_in 'Name', with: 'New Tech Company E'
      fill_in 'Rule', with: '+'
      click_button('Create')

      assert find('#errorExplanation ul li', text: 'Rule must be regular expressions.')
      assert_equal current_path, '/groups/11/assign_rules'
      assert_equal 'New Tech Company E', find('input#assign_rule_name').value
      assert_equal '+', find('input#assign_rule_rule').value
    end

    def test_continue_to_create_new_rule
      click_link('B Team')
      find('a#tab-rules').click
      click_link('New rule')

      fill_in 'Name', with: 'New Tech Company B'
      fill_in 'Rule', with: '.+@b.new-tech.com'
      click_button('Create and continue')

      assert find('div#flash_notice', text: 'Successful creation.')
      assert_equal '/groups/11/assign_rules/new', current_path
      fill_in 'Name', with: 'Old Tech Company B'
      fill_in 'Rule', with: '.+@b.old-tech.com'
      click_button('Create')

      assert find('div#flash_notice', text: 'Successful creation.')
      assert_equal '/groups/11/edit', current_path
      assert find('td.name', text: 'New Tech Company B')
      assert find('td.rule', text: '.+@b.new-tech.com')
      assert find('td.name', text: 'Old Tech Company B')
      assert find('td.rule', text: '.+@b.old-tech.com')
    end

    def test_edit_rule
      click_link('B Team')
      find('a#tab-rules').click
      click_link('For edit test')

      fill_in 'Name', with: 'After edit name'
      fill_in 'Rule', with: '.+@after.edit.test.net'
      click_button('Save')

      assert find('div#flash_notice', text: 'Successful update.')
      assert_equal '/groups/11/edit', current_path
      assert find('td.name', text: 'After edit name')
      assert find('td.rule', text: '.+@after.edit.test.net')
    end

    def test_fail_to_edit_rule_with_invalid_regexp
      click_link('B Team')
      find('a#tab-rules').click
      click_link('ABC Example')

      fill_in 'Rule', with: '*'
      click_button('Save')

      assert find('#errorExplanation ul li', text: 'Rule must be regular expressions.')
      assert current_path.start_with?('/groups/11/assign_rules/')
      assert_equal 'ABC Example', find('input#assign_rule_name').value
      assert_equal '*', find('input#assign_rule_rule').value
    end

    def test_delete_rule
      click_link('B Team')
      find('a#tab-rules').click

      within(:css, 'tr#rule-5') do
        click_link('Delete')
      end
      page.accept_alert

      short_wait_time do
        assert_raise Capybara::ElementNotFound do
          find('tr#rule-5')
        end
      end
    end
  end
end
