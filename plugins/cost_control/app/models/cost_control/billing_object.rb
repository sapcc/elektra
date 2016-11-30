module CostControl
  class BillingObject < Core::ServiceLayer::Model

    def availability_zone
      attributes.fetch('AZ', '')
    end

    def project_id
      attributes.fetch('PROJECT_ID', '')
    end

    def service
      attributes.fetch('SERVICE', '')
    end

    def object_id
      attributes.fetch('OBJECT_ID', '')
    end

    def duration
      attributes.fetch('DURATION', '')
    end

    def storage
      attributes.fetch('STORAGE', '')
    end

    def price_storage_loc
      attributes.fetch('PRICE_STORAGE_LOC', '')
    end

    def price_storage_sec
      attributes.fetch('PRICE_STORAGE_SEC', '')
    end

    def price_loc
      attributes.fetch('PRICE_LOC', '')
    end

    def price_sec
      attributes.fetch('PRICE_SEC', '')
    end

    def cost_object
      attributes.fetch('COST_OBJECT', '')
    end

    def cost_object_type
      attributes.fetch('COST_OBJECT_TYPE', '')
    end

    def project_name
      attributes.fetch('PROJECT_NAME' ,'')
    end

    def co_inherited
      attributes.fetch('CO_INHERITED', '')
    end

    def to_s
      self.name
    end

  end
end