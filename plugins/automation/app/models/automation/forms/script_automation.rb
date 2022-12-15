module Automation
  class Forms::ScriptAutomation < Forms::Automation
    validates :path, presence: true
  end
end
