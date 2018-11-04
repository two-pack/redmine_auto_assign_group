class AssignRuleGroupBuiltinException < RuntimeError; end

class AssignRule < ActiveRecord::Base
  include Redmine::SafeAttributes

  acts_as_positioned

  belongs_to :group

  validates_presence_of :name
  validate :rule_needs_to_be_regexp_on_mail, :rule_needs_to_be_regexp_on_firstname,
           :rule_needs_to_be_regexp_on_lastname, :rules_need_at_least_one

  scope :sorted, -> { order(:position) }

  safe_attributes 'group_id',
                  'name',
                  'mail',
                  'firstname',
                  'lastname',
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
    order(:position).reject { |e| user.email_address.address.match(e.mail).nil? ||
                                  user.firstname.match(e.firstname).nil? ||
                                  user.lastname.match(e.lastname).nil? }
                    .map    { |e| Group.find(e.group_id) }
                    .uniq
  end

  def rule_needs_to_be_regexp(target, rule)
    Regexp.compile(rule)
  rescue RegexpError
    errors.add(target, :error_raag_rule_must_be_regexp)
  end

  def rule_needs_to_be_regexp_on_mail
    rule_needs_to_be_regexp(:mail, mail)
  end

  def rule_needs_to_be_regexp_on_firstname
    rule_needs_to_be_regexp(:firstname, firstname)
  end

  def rule_needs_to_be_regexp_on_lastname
    rule_needs_to_be_regexp(:lastname, lastname)
  end

  def rules_need_at_least_one
    if mail.empty? && firstname.empty? && lastname.empty? then
      errors.add(:base, :error_raag_rule_must_be_entered_at_least_one)
    end
  end
end
