# Mg::Choice represents a split of an a/b test
#
# Attributes
# mg_test_id:: ID of Mg::Test which this is a choice for
# name:: 
# value:: The value to serve when this choice comes up (assuming non-switch)
# opt1:: Optional additional data
# opt2:: Optional additional data
# served:: Number of times this choice has been served
# reward:: Total accumulated reward for this choice
# reward_count:: How many rewards factor into this total
# switch_type:: Is this a switch-type choice
# deleted_at:: Is this choice still active?
class Mg::Choice < ActiveRecord::Base
  set_table_name :mg_choices
  
  # ActiveRecord Associations
  belongs_to :mg_test, :class_name => "Mg::Test"
  
  # Validations
  validates_presence_of :name
  validates_presence_of :mg_test_id
  
  # Member Functions
  
  # Mark that we have served this choice 
  def tally_serve
    self.transaction do
      self.update_attribute(:reward, 0) if self.reward.nil? #we should merge this with the next line, but whatever
      Mg::Choice.update_counters(self.id, :served => 1)
    end
    
    return self.reload
  end
  
  # Reward has a "default" or adjustable setting
  def tally_goal(goal, reward)
    self.transaction do
      Mg::Choice.update_counters(self.id, :reward_count => 1, :reward => reward)
    end
    
    return self.reload
  end
  
  # What is the average reward given to this choice
  def reward_rate
    return nil if self.reward_count == 0 || self.reward_count.nil? || self.reward.nil?
    return self.reward / self.reward_count.to_f
  end
end
