module RequestorModel
  extend ActiveSupport::Concern

  included do
    self.table_name_prefix = 'requestor'
  end
end