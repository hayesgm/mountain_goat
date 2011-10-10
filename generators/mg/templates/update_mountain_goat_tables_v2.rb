class UpdateMountainGoatTablesV2 < ActiveRecord::Migration

  def self.up
    rename_table :mg_ci_metas, :mg_gi_metas
    rename_table :mg_cs_metas, :mg_gs_metas
    rename_table :mg_convert_meta_types, :mg_goal_meta_types
    rename_table :mg_converts, :mg_goals
    rename_table :mg_metric_variants, :mg_choices
    rename_table :mg_metrics, :mg_tests
    rename_table :mg_rallies, :mg_records
    
    rename_column :mg_gi_metas, :rally_id, :mg_record_id
    rename_column :mg_gi_metas, :convert_meta_type_id, :mg_goal_meta_type_id
    rename_column :mg_goal_meta_types, :convert_id, :mg_goal_id
    add_column :mg_goal_meta_types, :is_hidden, :boolean, :default => false
    rename_column :mg_goals, :convert_type, :goal_type
    remove_column :mg_goals, :reward
    add_column :mg_goals, :is_hidden, :boolean, :default => false
    rename_column :mg_gs_metas, :rally_id, :mg_record_id
    rename_column :mg_gs_metas, :convert_meta_type_id, :mg_goal_meta_type_id
    rename_column :mg_choices, :metric_id, :mg_test_id
    rename_column :mg_choices, :conversions, :reward_count
    rename_column :mg_tests, :metric_type, :test_type
    add_column :mg_tests, :is_hidden, :boolean, :default => false
    rename_column :mg_records, :convert_id, :mg_goal_id
    rename_column :mg_report_items, :report_id, :mg_report_id
    
    add_column :mg_goals, :rewards_given, :integer, :default => 0
    add_column :mg_goals, :rewards_total, :float
    add_column :mg_records, :reward, :float
    
    add_column :mg_reports, :report_type, :string, :default => 'graph'
    add_column :mg_reports, :report_opts, :text
    add_column :mg_reports, :meta, :string
    add_column :mg_reports, :meta2, :string
  end

  def self.down
    rename_table :mg_gi_metas, :mg_ci_metas
    rename_table :mg_gs_metas, :mg_cs_metas
    rename_table :mg_goal_meta_types, :mg_convert_meta_types 
    rename_table :mg_goals, :mg_converts
    rename_table :mg_choices, :mg_metric_variants
    rename_table :mg_tests, :mg_metrics
    rename_table :mg_records, :mg_rallies
    
    rename_column :mg_gi_metas, :mg_record_id, :rally_id
    rename_column :mg_gi_metas, :mg_goal_meta_type_id, :convert_meta_type_id
    rename_column :mg_goal_meta_types, :mg_goal_id, :convert_id
    remove_column :mg_goal_meta_types, :is_hidden
    rename_column :mg_goals, :goal_type, :convert_type
    add_column :mg_goals, :reward, :float
    remove_column :mg_goals, :is_hidden
    rename_column :mg_gs_metas, :mg_record_id, :rally_id
    rename_column :mg_gs_metas, :mg_goal_meta_type_id, :convert_meta_type_id
    rename_column :mg_choices, :mg_test_id, :metric_id
    rename_column :mg_choices, :reward_count, :conversions
    rename_column :mg_tests, :test_type, :metric_type
    remove_column :mg_tests, :is_hidden
    rename_column :mg_records, :mg_goal_id, :convert_id
    rename_column :mg_report_items, :mg_report_id, :report_id
    
    remove_column :mg_goals, :rewards_given
    remove_column :mg_goals, :rewards_total
    remove_column :mg_records, :reward
    
    remove_column :mg_reports, :report_type
    remove_column :mg_reports, :report_opts
    remove_column :mg_reports, :meta
    remove_column :mg_reports, :meta2
  end

end
