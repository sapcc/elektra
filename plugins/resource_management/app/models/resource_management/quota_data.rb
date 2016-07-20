module ResourceManagement
  class QuotaData
    attr_reader :name, :usage, :total, :unit
    def initialize(options={})
      options.each do |name, value|
        self.instance_variable_set("@#{name}",value)
      end
    end
    
    def available
      (total.to_i-usage.to_i)
    end
    
    def display_string
      value = available
      value = value_to_human(value,unit.to_s) if unit
      "#{value} #{name.humanize}"
    end
    
    private
    
    UNIT_VALUES = ['byte','kb','mb','gb','tb']
    
    def value_to_human(value,unit)
      index = UNIT_VALUES.index(unit.to_s.downcase)
      new_value = value/1024
      if new_value < 1 or index==UNIT_VALUES.length-1
        value = value.round(2) if value.is_a?(Float)
        unit_string = unit.to_s.downcase=='byte' ? 'Byte' : unit.to_s.upcase
        "#{value}#{unit_string}"
      else
        value_to_human(new_value,UNIT_VALUES[index+1])
      end  
    end
  end
end