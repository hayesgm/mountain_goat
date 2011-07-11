class MountainGoatAddMgOptionsTable < ActiveRecord::Migration
  def self.up
    create_table :mountain_goat_options do |t|
    end
  end

  def self.down
    drop_table :mountain_goat_options
  end
end
