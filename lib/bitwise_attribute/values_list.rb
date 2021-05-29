# frozen_string_literal: true

module BitwiseAttribute
  class ValuesList < Array
    def initialize(field, record, values)
      super(concat(values))

      @field = field
      @record = record
    end

    def <<(value)
      concat(Array(value))

      @record.send("#{@field}=", self)
    end
  end
end
