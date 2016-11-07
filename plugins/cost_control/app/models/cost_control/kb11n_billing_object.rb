module CostControl
  class Kb11nBillingObject < Core::ServiceLayer::Model
    # The following properties are known:

    def doc_date
      attributes.fetch('Doc.date', '')
    end

    def doc_headertext
      attributes.fetch('Doc.headertext', '')
    end

    def send_pers_no
      attributes.fetch('Send.Pers.no', '')
    end

    def send_costcenter
      attributes.fetch('Send.CostCtr', '')
    end

    def send_order
      attributes.fetch('Send.Order', '')
    end

    def send_salesorder
      attributes.fetch('Send.SalesOrder', '')
    end

    def send_salesitem
      attributes.fetch('Send.SalesItem', '')
    end

    def send_wbs
      attributes.fetch('Send.WBS', '')
    end

    def send_network
      attributes.fetch('Send.Network', '')
    end

    def cost_element
      attributes.fetch('Cost_elem.', '')
    end

    def costs
      attributes.fetch('Costs', '')
    end

    def currency
      attributes.fetch('Tr.Crcy', '')
    end

    def quantity
      attributes.fetch('Quantity', '')
    end

    def unit
      attributes.fetch('Unit', '')
    end

    def rec_costcenter
      attributes.fetch('Rec.CostCtr', '')
    end

    def rec_order
      attributes.fetch('Rec.Order', '')
    end

    def rec_salesorder
      attributes.fetch('Rec.SalesOrd.', '')
    end

    def rec_salesitem
      attributes.fetch('Rec.SalesItem', '')
    end

    def rec_wbs
      attributes.fetch('Rec.WBS', '')
    end

    def rec_network
      attributes.fetch('Rec.Network', '')
    end

    def item_text
      attributes.fetch('Item_text', '')
    end

    def to_s
      self.name
    end

  end
end
