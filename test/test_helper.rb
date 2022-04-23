require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

require 'capybara/rails'
require 'selenium-webdriver'

Capybara.register_driver :headless_chrome do |app|
  if Redmine::VERSION::MAJOR >= 4
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_option('w3c', true)
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('window-size=1280,800')
    Capybara::Selenium::Driver.new(
        app,
        browser: :chrome,
        options: options
    )
  else
    Capybara::Selenium::Driver.new(
        app,
        browser: :chrome,
        switches: %w[--headless --disable-gpu --no-sandbox window-size=1280,800]
    )
  end
end

Capybara.javascript_driver = :headless_chrome
Capybara.current_driver = :headless_chrome
Capybara.default_max_wait_time = 10

module RedmineAutoAssignGroup
  module IntegrationTestHelper
    include Capybara::DSL

    def login(user, password)
      visit '/login'
      fill_in 'username', with: user
      fill_in 'password', with: password
      find('input#login-submit').click
      assert find('a.logout', visible: :all)
    end

    def logout
      find('a.logout').click
      assert find('a.login', visible: :all)
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

    def assert_visit
      assert has_selector?("div#content")
    end
  end
end
