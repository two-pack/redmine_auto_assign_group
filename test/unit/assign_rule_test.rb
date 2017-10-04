require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineAutoAssignGroup
  class AssignRuleTest < ActiveSupport::TestCase
    fixtures :email_addresses

    ActiveRecord::FixtureSet.create_fixtures(
        File.dirname(__FILE__) + '/../fixtures/', [:assign_rules, :users])

    def test_compare_position
      less  = AssignRule.new(:group_id => 11, :name => 'left',  :rule => '.*', :position => 1)
      greater = AssignRule.new(:group_id => 11, :name => 'right', :rule => '.*', :position => 2)

      assert_equal -1, less <=> greater
      assert_equal 0, less <=> less
      assert_equal 1, greater <=> less
    end

    def test_match_group_by_user
      groups = AssignRule.match_groups(User.find(1))   # admin@somenet.foo

      assert_equal 2, groups.count
      assert_equal 11, groups[0].id   # B Team
      assert_equal 14, groups[1].id   # C Team
    end

    def test_raise_error_with_invalid_regexp
      rule = AssignRule.new(:group_id => 11, :name => 'invalid rule', :rule => '*', :position => 1)

      rule.rule_needs_to_be_regexp

      assert_equal ['must be regular expressions.'], rule.errors[:rule]
    end

    def test_raise_error_with_groups_non_member
      assert_raise AssignRuleGroupBuiltinException do
        AssignRule.new(:group_id => 12, :name => 'Non member users', :rule => 'groups_non_member@example.com', :position => 1)
      end
    end

    def test_raise_error_with_groups_anonymous
      assert_raise AssignRuleGroupBuiltinException do
        AssignRule.new(:group_id => 13, :name => 'Anonymous users', :rule => 'groups_anonymous@example.com', :position => 1)
      end
    end

  end
end