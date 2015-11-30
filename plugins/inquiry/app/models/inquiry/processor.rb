module Inquiry
  class Processor < ActiveRecord::Base
    has_and_belongs_to_many :inquiries
  end
end
