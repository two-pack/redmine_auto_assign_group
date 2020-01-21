require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineAutoAssignGroup
  class UserTest < ActiveSupport::TestCase
    fixtures :groups_users
    ActiveRecord::FixtureSet.create_fixtures(
        File.dirname(__FILE__) + '/../fixtures/', [:users, :assign_rules]
    )

    def test_create_with_rule
      user = User.new(firstname: 'user1', lastname: 'test',
                      mail: 'user1.test@abc.example.com')
      user.login = 'user1.test'
      assert user.save

      assert 11, user.groups.first.id
    end

    def test_create_without_rule
      user = User.new(firstname: 'user2', lastname: 'test',
                      mail: 'user2.test@norule.example.com')
      user.login = 'user2.test'
      assert user.save

      assert 0, user.groups.count
    end

    def test_create_with_invalid_email_address
      user = User.new(firstname: 'user3', lastname: 'test',
                      mail: 'user3')
      user.login = 'user3.test'
      assert !user.save
    end

    def test_edit_do_not_affects_auto_assign_group
      user = User.new(firstname: 'user4', lastname: 'test',
                      mail: 'user4.test@norule.example.com')
      user.login = 'user4.test'
      assert user.save
      assert 0, user.groups.count

      user.email_address.address = 'user4.test@abc.example.com'
      assert user.save
      assert 0, user.groups.count
    end
  end
end
