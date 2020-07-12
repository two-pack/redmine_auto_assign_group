require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineAutoAssignGroup
  class GroupsRulesTabTest < Redmine::IntegrationTest
    fixtures :email_addresses, :groups_users
    ActiveRecord::FixtureSet.create_fixtures(
      File.dirname(__FILE__) + '/../fixtures/', [:assign_rules, :users]
    )

    include RedmineAutoAssignGroup::IntegrationTestHelper

    def open_rules_tab(group_number)
      Retryable.retryable(tries: 10) do
        visit '/groups/' + group_number.to_s + '/edit'
        assert_visit
        find('a#tab-rules').click
      end
    end

    def setup
      login_with_admin

      visit '/groups'
      assert_visit
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
      assert find('#content > h2', text: '403')
    end

    def test_do_not_show_rules_when_no_rules
      open_rules_tab(16)  # Empty Group

      assert find('p.nodata', text: 'No data to display')
    end

    def test_show_rules
      open_rules_tab(11)  # B Team

      within(:css, 'tr#rule-1') do
        assert find('td.name', text: 'ABC Example')
        assert find('td.rule-mail', text: '.+@abc.example.com')
        assert find('td.rule-firstname', text: '')
        assert find('td.rule-lastname', text: '')
      end

      within(:css, 'tr#rule-2') do
        assert find('td.name', text: 'XYZ Corp')
        assert find('td.rule-mail', text: '.+@xyz.corp.co.jp')
        assert find('td.rule-firstname', text: 'Tatsuya')
        assert find('td.rule-lastname', text: '')
      end

      within(:css, 'tr#rule-3') do
        assert find('td.name', text: 'PQR Inc.')
        assert find('td.rule-mail', text: '.+@pqr.net')
        assert find('td.rule-firstname', text: '')
        assert find('td.rule-lastname', text: 'Saito')
      end
    end

    def test_create_new_rule
      open_rules_tab(11)  # B Team
      click_link('New rule')

      fill_in 'Name', with: 'New Tech Company A'
      fill_in 'Email', with: '.+@a.new-tech.com'
      fill_in 'First name', with: 'Yoji'
      fill_in 'Last name', with: 'Yamada'
      click_button('Create')

      assert find('div#flash_notice', text: 'Successful creation.')
      assert_equal '/groups/11/edit', current_path
      assert find('td.name', text: 'New Tech Company A')
      assert find('td.rule-mail', text: '.+@a.new-tech.com')
      assert find('td.rule-firstname', text: 'Yoji')
      assert find('td.rule-lastname', text: 'Yamada')
    end

    def test_fail_to_create_new_rule_with_invalid_regexp
      open_rules_tab(11)  # B Team
      click_link('New rule')

      fill_in 'Name', with: 'New Tech Company E'
      fill_in 'Email', with: '+'
      click_button('Create')

      assert find('#errorExplanation ul li', text: 'Email must be regular expressions.')
      assert_equal current_path, '/groups/11/assign_rules'
      assert_equal 'New Tech Company E', find('input#assign_rule_name').value
      assert_equal '+', find('input#assign_rule_mail').value
    end

    def test_continue_to_create_new_rule
      open_rules_tab(11)  # B Team
      click_link('New rule')

      fill_in 'Name', with: 'New Tech Company B'
      fill_in 'Email', with: '.+@b.new-tech.com'
      find('input[name="continue"]').click

      assert find('div#flash_notice', text: 'Successful creation.')
      assert_equal '/groups/11/assign_rules/new', current_path
      fill_in 'Name', with: 'Old Tech Company B'
      fill_in 'Email', with: '.+@b.old-tech.com'
      click_button('Create')

      assert find('div#flash_notice', text: 'Successful creation.')
      assert_equal '/groups/11/edit', current_path
      assert find('td.name', text: 'New Tech Company B')
      assert find('td.rule-mail', text: '.+@b.new-tech.com')
      assert find('td.name', text: 'Old Tech Company B')
      assert find('td.rule-mail', text: '.+@b.old-tech.com')
    end

    def test_edit_rule
      open_rules_tab(11)  # B Team
      click_link('For edit test')

      fill_in 'Name', with: 'After edit name'
      fill_in 'Email', with: '.+@after.edit.test.net'
      click_button('Save')

      assert find('div#flash_notice', text: 'Successful update.')
      assert_equal '/groups/11/edit', current_path
      assert find('td.name', text: 'After edit name')
      assert find('td.rule-mail', text: '.+@after.edit.test.net')
    end

    def test_fail_to_edit_rule_with_invalid_regexp
      open_rules_tab(11)  # B Team
      click_link('ABC Example')

      fill_in 'Email', with: '*'
      click_button('Save')

      assert find('#errorExplanation ul li', text: 'Email must be regular expressions.')
      assert current_path.start_with?('/groups/11/assign_rules/')
      assert_equal 'ABC Example', find('input#assign_rule_name').value
      assert_equal '*', find('input#assign_rule_mail').value
    end

    def test_delete_rule
      open_rules_tab(11)  # B Team

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
