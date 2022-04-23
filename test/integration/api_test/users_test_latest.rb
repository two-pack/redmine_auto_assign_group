require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module RedmineAutoAssignGroup
  class Redmine::ApiTest::UsersTest < Redmine::ApiTest::Base
    fixtures :email_addresses, :members, :member_roles, :roles, :projects,
             :groups_users
    ActiveRecord::FixtureSet.create_fixtures(
      File.dirname(__FILE__) + '/../../fixtures/', [:users, :assign_rules]
    )

    content_type_charset = (Redmine::VERSION::MAJOR >= 5) ? "; charset=utf-8" : ""

    test 'POST /users.xml with valid parameters should automatically assign group for new user' do
      assert_difference('User.count') do
        post '/users.xml',
             params: {
               user: {
                 login: 'foo', firstname: 'Firstname', lastname: 'Lastname',
                 mail: 'foo@abc.example.com', password: 'secret123',
                 mail_notification: 'only_assigned'
               }
             },
             headers: credentials('admin')
      end

      user = User.order('id DESC').first
      assert_equal 11, user.groups.first.id
    end

    test 'POST /users.json with valid parameters should automatically assign group for new user' do
      assert_difference('User.count') do
        post '/users.json',
             params: {
               user: {
                 login: 'foo', firstname: 'Firstname', lastname: 'Lastname',
                 mail: 'foo@abc.example.com', password: 'secret123',
                 mail_notification: 'only_assigned'
               }
             },
             headers: credentials('admin')
      end

      user = User.order('id DESC').first
      assert_equal 11, user.groups.first.id
    end

    test 'POST /users.xml with with invalid parameters should return errors' do
      assert_no_difference('User.count') do
        post '/users.xml',
             params: {
               user: {
                 login: 'foo', lastname: 'Lastname', mail: 'foo'
               }
             },
             headers: credentials('admin')
      end

      assert_response :unprocessable_entity      
      assert_equal 'application/xml' + content_type_charset, @response.content_type
      assert_select 'errors error', text: 'First name cannot be blank'
    end

    test 'POST /users.json with with invalid parameters should return errors' do
      assert_no_difference('User.count') do
        post '/users.json',
             params: {
               user: {
                 login: 'foo', lastname: 'Lastname', mail: 'foo'
               }
             },
             headers: credentials('admin')
      end

      assert_response :unprocessable_entity
      assert_equal 'application/json' + content_type_charset, @response.content_type
      json = ActiveSupport::JSON.decode(response.body)
      assert_kind_of Hash, json
      assert json.key?('errors')
      assert_kind_of Array, json['errors']
    end
  end
end
