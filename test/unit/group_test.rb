require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineAutoAssignGroup
  class GroupTest < ActiveSupport::TestCase
    ActiveRecord::FixtureSet.create_fixtures(
      File.dirname(__FILE__) + '/../fixtures/', [:users, :assign_rules]
    )

    def test_destroy_with_rules
      Group.find(11).destroy

      assert_equal 0, AssignRule.where(group_id: 11).count
    end
  end
end
