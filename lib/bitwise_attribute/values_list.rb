module BitwiseAttribute
  class ValuesList < Array
    def initialize(field, record, values)
      @field = field
      @record = record

      concat(values)
    end

    def <<(value)
      concat(Array(value))

      @record.send("#{@field}=", self)
    end
  end
end
