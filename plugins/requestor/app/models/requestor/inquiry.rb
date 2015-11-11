module Requestor
  class Inquiry < ActiveRecord::Base

    include AASM

    has_many :process_steps

    aasm do

      state :open, :initial => true #, :before_enter => :do_something
      state :approved
      state :rejected

      after_all_transitions Proc.new {|*args| log_process_step(*args)}

      event :approve do
        transitions :from => :open, :to => :approved #, :after => Proc.new {|*args| save_process_step(*args)}
      end

      event :reject do
        transitions :from => :open, :to => :rejected
      end

      event :reopen do
        transitions :from => :rejected, :to => :open
      end

    end

    def log_process_step(options = {})
      step = Requestor::ProcessStep.new
      step.from_state = aasm.from_state
      step.to_state = aasm.to_state
      step.event = aasm.current_event
      step.processor_id = options[:user_id]
      step.description = options[:description]
      self.process_steps << step
    end

  end
end
