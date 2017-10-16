require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

require 'capybara/rails'
require 'capybara/poltergeist'

module RedmineAutoAssignGroup
  module IntegrationTestHelper
    include Capybara::DSL

    Capybara.default_driver = :poltergeist
    Capybara.javascript_driver = :poltergeist
    Capybara.default_max_wait_time = 10

    def login(user, password)
      visit '/login'
      fill_in 'username', with: user
      fill_in 'password', with: password
      click_button('Login')
      assert_equal 200, page.status_code
      assert page.find('a.logout', visible: :all)
    end

    def logout
      click_link('Sign out')
      assert_equal 200, page.status_code
      assert page.find('a.login', visible: :all)
    end

    def login_with_admin
      login 'admin', 'admin'
    end

    def login_with_user
      login 'jsmith', 'jsmith'
    end

    def short_wait_time
      default_wait_time = Capybara.default_max_wait_time
      Capybara.default_max_wait_time = 1
      yield
      Capybara.default_max_wait_time = default_wait_time
    end

    def wait_for_ajax
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop until finished_all_ajax_requests?
      end
    end

    def finished_all_ajax_requests?
      page.evaluate_script('jQuery.active').zero?
    end
  end
end
