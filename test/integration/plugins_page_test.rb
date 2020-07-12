require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineAutoAssignGroup
  class PluginsPageTest < Redmine::IntegrationTest
    ActiveRecord::FixtureSet.create_fixtures(
      File.dirname(__FILE__) + '/../fixtures/', [:users]
    )

    include RedmineAutoAssignGroup::IntegrationTestHelper

    def setup
      login_with_admin

      visit '/admin/plugins'
      assert_visit
    end

    def teardown
      logout
    end

    def test_this_plugin_is_shown_on_plugin_page
      within(:css, 'tr#plugin-redmine_auto_assign_group td.name') do
        assert page.has_css?('span.name', text: 'Redmine Auto Assign Group Plugin')
        assert page.has_css?('span.description', text: 'This plugin automatically assigns group when user is added.')
        assert page.has_css?('span.url a', text: 'https://github.com/two-pack/redmine_auto_assign_group')
      end
    end
  end
end
