module Inquiry
  class Inquiry < ActiveRecord::Base
    include Filterable
    paginates_per 3

    has_many :process_steps
    has_and_belongs_to_many :processors

    attr_accessor :process_step_description
    validates :process_step_description, presence: {message: 'Please provide a description for the process action'}

    scope :id, -> (id) { where id: id }
    scope :state, -> (state) { where aasm_state: state }
    scope :requester_id, -> (requester_id) { where requester_id: requester_id }
    scope :kind, -> (kind) { where kind: kind }


    include AASM
    aasm do

      state :open, :initial => true, :before_enter => :set_process_step_description
      state :approved
      state :rejected

      #after_all_transitions Proc.new {|*args| log_process_step(*args)}

      event :approve do
        transitions :from => :open, :to => :approved, :after => Proc.new { |*args| log_process_step(*args) }, :guards => [:can_approve?]
      end

      event :reject do
        transitions :from => :open, :to => :rejected, :after => Proc.new { |*args| log_process_step(*args) }, :guards => [:can_reject?]
      end

      event :reopen do
        transitions :from => :rejected, :to => :open, :after => Proc.new { |*args| log_process_step(*args) }, :guards => [:can_reopen?]
      end

    end

    def set_process_step_description
      self.process_step_description = "Initial creation"
    end

    def log_process_step(options = {})
      step = ProcessStep.new
      step.from_state = aasm.from_state
      step.to_state = aasm.to_state
      step.event = aasm.current_event
      step.processor_id = options[:user_id]
      step.description = options[:description]
      self.process_steps << step
    end

    def can_approve?
      self.open?
    end

    def can_reopen?
      self.rejected?
    end

    def can_reject?
      self.open?
    end

    def actions_allowed
      actions = self.aasm.states(:permitted => true).map(&:name)
      actions.unshift(self.aasm_state)
      return actions
    end

  end
end
