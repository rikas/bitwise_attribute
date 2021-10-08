# frozen_string_literal: true

module BitwiseAttribute
  module ActiveRecordMethods
    def define_named_scopes(name, column_name, mapping)
      define_singleton_method("with_#{name}") do |*keys|
        keys = cleanup_keys(keys, mapping)

        return none unless keys&.any?

        records = all

        keys.each do |key|
          records = records.where((arel_table[column_name] & mapping[key]).eq(mapping[key]))
        end

        records
      end

      define_singleton_method("with_any_#{name}") do |*keys|
        keys = cleanup_keys(keys, mapping)

        return where.not(column_name => nil) unless keys&.any?

        records = where('1=0')

        keys.each do |key|
          records = records.or(where((arel_table[column_name] & mapping[key]).eq(mapping[key])))
        end

        records
      end

      define_singleton_method("with_exact_#{name}") do |*keys|
        keys = cleanup_keys(keys, mapping)

        return none unless keys&.any?

        records = send("with_#{name}", keys)

        (mapping.keys - keys).each do |key|
          records = records.where((arel_table[column_name] & mapping[key]).not_eq(mapping[key]))
        end

        records
      end

      define_singleton_method("without_#{name}") do |*keys|
        keys = cleanup_keys(keys, mapping)

        return where(column_name => nil).or(where(column_name => 0)) unless keys&.any?

        records = all

        keys.each do |key|
          records = records.where((arel_table[column_name] & mapping[key]).not_eq(mapping[key]))
        end

        records
      end

      # Defines a class method for each key of the mapping, returning records that have *at least*
      # the corresponding value.
      mapping.each_key do |key|
        define_singleton_method(key) do
          send("with_#{name}", key)
        end
      end
    end

    def cleanup_keys(keys, mapping)
      return [] unless keys

      clean = keys.flatten.map(&:to_sym).compact.uniq

      clean & mapping.keys # only roles that we know about
    end
  end
end
