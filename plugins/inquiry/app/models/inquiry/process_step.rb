module Inquiry
  class ProcessStep < ApplicationRecord
    belongs_to :inquiry
    belongs_to :processor
  end
end
