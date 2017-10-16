class AssignRuleGroupBuiltinException < RuntimeError; end

class AssignRule < ActiveRecord::Base
  include Redmine::SafeAttributes

  acts_as_positioned

  belongs_to :group

  validate :rule_needs_to_be_regexp

  scope :sorted, -> { order(:position) }

  safe_attributes 'group_id',
                  'name',
                  'rule',
                  'position'

  def initialize(attributes = nil)
    unless attributes.nil?
      group = Group.find(attributes[:group_id])
      raise AssignRuleGroupBuiltinException if group.builtin?
    end

    super
  end

  def <=>(rule)
    position <=> rule.position
  end

  def self.match_groups(user)
    order(:position).reject { |e| user.email_address.address.match(e.rule).nil? }
                    .map    { |e| Group.find(e.group_id) }
  end

  def rule_needs_to_be_regexp
    Regexp.compile(rule)
  rescue RegexpError
    errors.add(:rule, :error_raag_rule_must_be_regexp)
  end
end
