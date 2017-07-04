class CreateAssignRules < ActiveRecord::CompatibleLegacyMigration.migration_class
  def change
    create_table :assign_rules do |t|
      t.belongs_to :group
      t.string :name, null: false
      t.string :rule, null: false
      t.integer :position
      t.index [:position], name: :index_assign_rules_on_position
    end
  end
end
