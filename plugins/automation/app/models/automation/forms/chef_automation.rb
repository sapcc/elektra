module Automation
  class Forms::ChefAutomation < Forms::Automation
    validates :run_list, presence: true
  end
end
