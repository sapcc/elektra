module Inquiry
  class ProcessStep < ActiveRecord::Base
    belongs_to :inquiry
    belongs_to :processor

  end
end
