# frozen_string_literal: true

module BitwiseAttribute
  module ActiveRecordMethods
    def define_named_scopes(name, column_name, mapping)
      define_singleton_method("with_#{name}") do |*keys|
        keys = cleanup_keys(keys)

        return [] unless keys&.any?

        records = where("#{column_name} & #{mapping[keys.first]} = #{mapping[keys.first]}")

        keys[1..-1].each do |key|
          records = records.where("#{column_name} & #{mapping[key]} = #{mapping[key]}")
        end

        records
      end

      define_singleton_method("with_any_#{name}") do |*keys|
        keys = cleanup_keys(keys)

        return where.not(column_name => nil) unless keys&.any?

        records = where("#{column_name} & #{mapping[keys.first]} = #{mapping[keys.first]}")

        keys[1..-1].each do |key|
          records = records.or(where("#{column_name} & #{mapping[key]} = #{mapping[key]}"))
        end

        records
      end

      define_singleton_method("with_exact_#{name}") do |*keys|
        keys = cleanup_keys(keys)

        return [] unless keys&.any?

        records = send("with_#{name}", keys)

        (mapping.keys - keys).each do |key|
          records = records.where("#{column_name} & #{mapping[key]} != #{mapping[key]}")
        end

        records
      end

      define_singleton_method("without_#{name}") do |*keys|
        keys = cleanup_keys(keys)

        return where(column_name => nil).or(where(column_name => 0)) unless keys&.any?

        records = where("#{column_name} & #{mapping[keys.first]} != #{mapping[keys.first]}")

        keys[1..-1].each do |key|
          records = records.where("#{column_name} & #{mapping[key]} != #{mapping[key]}")
        end

        records
      end

      # Defines a class method for each key of the mapping, returning records that have *at least*
      # the corresponding value.
      mapping.keys.each do |key|
        define_singleton_method(key) do
          send("with_#{name}", key)
        end
      end
    end

    def cleanup_keys(keys)
      return [] unless keys

      keys.flatten.map(&:to_sym).uniq
    end
  end
end
