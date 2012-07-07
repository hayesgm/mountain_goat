# Mg::Test represents something you are 'a/b testing'
# 
# Attributes
# test_type:: Symbol uniquely identifying this test (for code interaction)
# title:: Title of the test (E.g. Banner text)
# tally_each_serve:: Should we count each view by a user as a hit, or just first-serve to that user?
# is_switch:: Are we implementing a code-switch as opposed to a text substitution
# deleted_at:: Is this test deleted? (MG Console)
# is_hidden:: Is this test hidden? (MG Console)
class Mg::Test < ActiveRecord::Base
  self.table_name = 'mg_tests'
  
  # ActiveRecord Associations
  has_many :mg_choices, :class_name => "Mg::Choice", :foreign_key => "mg_test_id"
  
  # Validations
  validates_format_of :test_type, :with => /[a-z0-9_]{3,50}/i, :message => "must be between 3 and 30 characters, alphanumeric with underscores"
  validates_uniqueness_of :test_type
  
  # Member Functions
  
  # Get total reward of all choices for this test
  def total_reward
    self.mg_choices.map { |choice| choice.reward || 0 }.sum
  end
  
  # Get total served of all choices for this test
  def total_served
    self.mg_choices.map { |choice| choice.served || 0 }.sum
  end
end
