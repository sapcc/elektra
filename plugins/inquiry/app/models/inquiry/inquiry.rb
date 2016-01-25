module Inquiry
  class Inquiry < ActiveRecord::Base
    include Filterable
    paginates_per 3

    has_many :process_steps, -> { order(:created_at) }, dependent: :destroy

    belongs_to :requester, class_name: "Inquiry::Processor"
    has_and_belongs_to_many :processors

    validates :processors, presence: {message: 'missing. Please contact an administrator!'}
    validates :description, presence: true

    attr_accessor :process_step_description, :current_user
    validates :process_step_description, presence: {message: 'Please provide a description for the process action'}

    scope :id, -> (id) { where id: id }
    scope :state, -> (state) { where aasm_state: state }
    #scope :requester_id, -> (requester_id) { where requester_id: requester_id }
    scope :requester_id, -> (requester_id) { Inquiry.joins(:requester).where(inquiry_processors: {uid: requester_id}).includes(:requester) }
    scope :processor_id, -> (processor_id) { Inquiry.joins(:processors).where(inquiry_processors: {uid: processor_id}).includes(:processors) }
    scope :kind, -> (kind) { where kind: kind }
    scope :domain_id, -> (domain_id) { where domain_id: domain_id }

    after_create :transition_to_open


    include AASM
    aasm do

      #error_on_all_events :error_on_all_events

      state :new, :initial => true, :before_enter => :set_process_step_description
      state :open
      state :approved
      state :rejected
      state :closed

      event :open, :after => :notify_processors, :error => :error_on_event do
        transitions :from => :new, :to => :open, :after => Proc.new { |*args| log_process_step(*args) }
      end

      event :approve, :after => :notify_requester, :error => :error_on_event, :guards => Proc.new { |*args| can_approve?(*args) } do
        before do
          #run_automatically('approved')
        end
        transitions :from => :open, :to => :approved, :after => Proc.new { |*args| log_process_step(*args) }, :guards => [:can_approve?]
      end

      event :reject, :after => :notify_requester, :error => :error_on_event, :guards => Proc.new { |*args| can_reject?(*args) } do
        before do
          #run_automatically('rejected')
        end
        transitions :from => :open, :to => :rejected, :after => Proc.new { |*args| log_process_step(*args) }
      end

      event :reopen, :after => :notify_processors, :error => :error_on_event, :guards => Proc.new { |*args| can_reopen?(*args) } do
        transitions :from => :rejected, :to => :open, :after => Proc.new { |*args| log_process_step(*args) }, :guards => [:can_reopen?]
      end

      event :close, :error => :error_on_event, :guards => Proc.new { |*args| can_close?(*args) } do
        transitions :from => [:approved, :rejected], :to => :closed, :after => Proc.new { |*args| log_process_step(*args) }, :guards => [:can_close?]
      end

    end

    def error_on_event args
      raise args
    end

    def transition_to_open
      self.open!({description: self.process_step_description})
    end

    def set_process_step_description(options = {})
      self.process_step_description = "Initial creation!"
    end

    def run_automatically(state)
      if self.callbacks[state] && self.callbacks[state]['autorun'] && self.callbacks[state]['action']
        begin
          ret = eval(self.callbacks[state]['action'])
          puts ret
        rescue => e
          puts "ERROR"
        end
      end
    end

    def log_process_step(options = {})
      step = ProcessStep.new
      step.from_state = self.aasm_state
      step.to_state = aasm.to_state
      step.event = aasm.current_event
      if options[:user]
        step.processor = Processor.find_by_uid(options[:user].id)
      else
        step.processor = self.requester
      end
      step.description = options[:description]
      self.process_steps << step
    end

    def can_approve? options={}
      return self.open? && user_is_processor?(get_user_id(options[:user]))
    end

    def can_reopen? options={}
      return self.rejected? && user_is_requester?(get_user_id(options[:user]))
    end

    def can_reject? options={}
      return self.open? && user_is_processor?(get_user_id(options[:user]))
    end

    def can_close? options={}
      return user_is_processor?(get_user_id(options[:user])) || user_is_requester?(get_user_id(options[:user]))
    end

    def user_is_processor? user_id
      return true unless user_id
      if self.processors.find_by_uid(user_id)
        return true
      else
        return false
      end
    end

    def user_is_requester? user_id
      return true unless user_id
      if self.requester.uid == user_id
        return true
      else
        return false
      end
    end

    def events_allowed user
      self.current_user = user
      events = {}
      self.aasm.events(:permitted => true).each do |e|
        e.transitions.each do |t|
          events[t.to.to_sym] ||= []
          events[t.to.to_sym] << {event: e.name, name: Inquiry.aasm.human_event_name(e.name)}
        end
      end
      return events
    end

    def states_allowed user
      self.current_user = user
      events = events_allowed user
      states = []
      self.aasm.states(:permitted => true).each do |s|
        states << {state: s.name, name: s.display_name, events: events[s.name]}
      end

      return states
    end

    def get_user_id user
      if user
        return user.id
      elsif current_user
        return current_user.id
      else
        return nil
      end
    end

    def get_callback_action
      if self.callbacks.nil? || self.callbacks[self.aasm_state].nil?
        return nil
      else
        self.callbacks[self.aasm_state].name
      end
    end


    def notify_requester
      begin
        InquiryMailer.notification_email_requester(self.requester.email, self.requester.full_name, self.process_steps.last).deliver_later
      rescue Net::SMTPFatalError => e
        Rails.logger.error "InquiryMailer: Could not send email to requester #{@user_email}. Exception: #{e.message}"
      end
    end

    def notify_processors
      begin
        InquiryMailer.notification_email_processors((self.processors.map { |p| p.email }).compact, self.process_steps.last).deliver_later
      rescue Net::SMTPFatalError => e
        self.processors.each do |p|
          begin
            InquiryMailer.notification_email_processors([p.email], self.process_steps.last).deliver_later
          rescue Net::SMTPFatalError => ex
            Rails.logger.error "InquiryMailer: Could not send email to requester #{p.email}. Exception: #{ex.message}"
          end
        end
      end
    end

    def errors?
      return !self.errors.blank?
    end

  end
end
