module Inquiry
  class ProcessStep < ActiveRecord::Base
    belongs_to :inquiry
    belongs_to :processor

    #validates :description, presence: {message: 'Please provide a description for the process action'}

  end
end
