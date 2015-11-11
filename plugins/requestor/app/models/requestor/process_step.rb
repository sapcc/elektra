module Requestor
  class ProcessStep < ActiveRecord::Base
    belongs_to :inquiry
  end
end
