require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineAutoAssignGroup
  class AssignRuleTest < ActiveSupport::TestCase
    fixtures :email_addresses, :groups_users
    ActiveRecord::FixtureSet.create_fixtures(
        File.dirname(__FILE__) + '/../fixtures/', [:assign_rules, :users]
    )

    def test_compare_position
      less = AssignRule.new(group_id: 11, name: 'left', mail: '.*', position: 1)
      greater = AssignRule.new(group_id: 11, name: 'right', mail: '.*', position: 2)

      assert_equal -1, less <=> greater
      assert_equal 0, less <=> less
      assert_equal 1, greater <=> less
    end

    def test_match_group_by_user
      groups = AssignRule.match_groups(User.find(1)) # Redmine Admin admin@somenet.foo

      assert_equal 2, groups.count
      assert_equal 11, groups[0].id   # B Team
      assert_equal 14, groups[1].id   # C Team
    end

    def test_match_two_groups_by_user
      groups = AssignRule.match_groups(User.find(2)) # John Smith jsmith@somenet.foo

      assert_equal 2, groups.count
      assert_equal 11, groups[0].id   # B Team
      assert_equal 15, groups[1].id   # D Team
    end

    def test_raise_error_when_name_is_empty
      rule = AssignRule.new(group_id: 11, name: '', mail: '.+@example.com', position: 1)

      assert !rule.save
      assert_equal ['cannot be blank'], rule.errors[:name]
    end

    def test_raise_error_when_rule_is_all_empty
      rule = AssignRule.new(group_id: 11, name: 'foo', mail: '', firstname: '', lastname: '', position: 1)

      assert !rule.save
      assert_equal ['Please enter at least one rule.'], rule.errors[:base]
    end

    def test_not_raise_error_when_only_mail_is_empty
      rule = AssignRule.new(group_id: 11, name: 'foo', mail: '', firstname: 'John', lastname: 'Smith', position: 1)

      assert rule.save
    end

    def test_not_raise_error_when_only_firstname_is_empty
      rule = AssignRule.new(group_id: 11, name: 'foo', mail: 'foo@example.com', firstname: '', lastname: 'Smith', position: 1)

      assert rule.save
    end

    def test_not_raise_error_when_only_lastname_is_empty
      rule = AssignRule.new(group_id: 11, name: 'foo', mail: 'foo@example.com', firstname: 'John', lastname: '', position: 1)

      assert rule.save
    end

    def test_raise_error_with_invalid_regexp_on_mail
      rule = AssignRule.new(group_id: 11, name: 'invalid rule', mail: '*', firstname: '', lastname: '', position: 1)

      rule.rule_needs_to_be_regexp_on_mail
      assert_equal ['must be regular expressions.'], rule.errors[:mail]
    end

    def test_raise_error_with_invalid_regexp_on_firstname
      rule = AssignRule.new(group_id: 11, name: 'invalid rule', mail: '', firstname: '*', lastname: '', position: 1)

      rule.rule_needs_to_be_regexp_on_firstname
      assert_equal ['must be regular expressions.'], rule.errors[:firstname]
    end

    def test_raise_error_with_invalid_regexp_on_lastname
      rule = AssignRule.new(group_id: 11, name: 'invalid rule', mail: '', firstname: '', lastname: '*', position: 1)

      rule.rule_needs_to_be_regexp_on_lastname
      assert_equal ['must be regular expressions.'], rule.errors[:lastname]
    end

    def test_raise_error_with_groups_non_member
      assert_raise AssignRuleGroupBuiltinException do
        AssignRule.new(group_id: 12, name: 'Non member users', mail: 'groups_non_member@example.com', position: 1)
      end
    end

    def test_raise_error_with_groups_anonymous
      assert_raise AssignRuleGroupBuiltinException do
        AssignRule.new(group_id: 13, name: 'Anonymous users', mail: 'groups_anonymous@example.com', position: 1)
      end
    end
  end
end
