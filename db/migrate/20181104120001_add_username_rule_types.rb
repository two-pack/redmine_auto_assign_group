class AddUsernameRuleTypes < ActiveRecord::CompatibleLegacyMigration.migration_class
  def self.up
    rename_column :assign_rules, :rule, :mail
    add_column :assign_rules, :firstname, :string, :default => ''
    add_column :assign_rules, :lastname, :string, :default => ''
  end

  def self.down
    remove_column :assign_rules, :lastname
    remove_column :assign_rules, :firstname
    rename_column :assign_rules, :mail, :rule
  end
end
