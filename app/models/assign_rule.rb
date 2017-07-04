class AssignRule < ActiveRecord::Base
  include Redmine::SafeAttributes

  acts_as_positioned

  belongs_to :group

  validate :rule_needs_to_be_regexp

  scope :sorted, lambda { order(:position) }

  safe_attributes 'group_id',
                  'name',
                  'rule',
                  'position'

  def <=>(status)
    position <=> status.position
  end

  def self.match_groups(user)
    order(:position).reject { |e| user.email_address.address.match(e.rule).nil? }
                    .map    { |e| Group.find(e.group_id) }
  end

  def rule_needs_to_be_regexp
    begin
      Regexp.compile(rule)
    rescue RegexpError => e
      errors.add(:rule, :error_raag_rule_must_be_regexp)
    end
  end

end