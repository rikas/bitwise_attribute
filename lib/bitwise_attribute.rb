require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext'
require 'bitwise_attribute/version'
require 'bitwise_attribute/values_list'

module BitwiseAttribute
  extend ActiveSupport::Concern

  class_methods do
    def attr_bitwise(name, column_name: nil, values:)
      column_name ||= "#{name.to_s.singularize}_mask"

      # Check if the values is an array or hash with valid values. Raise ArgumentError otherwise.
      validate_values!(values)

      # Sets the constant <name.upcase>_MAPPING
      mapping = build_mapping(name, values)

      @mapping ||= {}
      @mapping[name] = mapping

      define_singleton_method(name) do
        @mapping[name]
      end

      define_method(name) do
        roles = value_getter(column_name, mapping)

        # This special array will call self.<name>= after changed
        ValuesList.new(name, self, roles)
      end

      define_method("#{name}=") do |new_values|
        value_setter(column_name, Array(new_values), mapping)
      end

      # Adds a boolean method for each key (ex: admin?)
      mapping.keys.each do |key|
        define_method("#{key}?") do
          value?(column_name, mapping[key])
        end
      end
    end

    # Builds internal bitwise key-value mapping it add a zero value, needed for bits operations.
    # Each sym get a power of 2 value
    def build_mapping(name, values)
      {}.tap do |hash|
        if values.is_a?(Hash)
          hash.merge!(values.sort_by { |_, value| value }.to_h)
        else
          values.each_with_index { |key, index| hash[key] = 2**index }
        end

        hash[:empty] = 0 # the default one
      end
    end

    # Validates the numeric values for each key. If it's not a power of 2 then raise ArgumentError.
    def validate_values!(values)
      return true if values.is_a?(Array)

      values.reject { |_, value| (Math.log2(value) % 1.0).zero? }.tap do |invalid_options|
        if invalid_options.any?
          raise(ArgumentError, "Values should be a power of 2 (#{invalid_options})")
        end
      end
    end
  end

  private

  # Return current value to symbols array
  #   Ex: 16 => [:slots, :credits]
  def value_getter(mask_column, mapping)
    mapping.values.reject { |value| (send(mask_column) & value).zero? }.map do |value|
      mapping.invert[value]
    end
  end

  # Set current values from values array
  def value_setter(mask_column, values, mapping)
    send("#{mask_column}=", 0)

    values.each do |value|
      raise(ArgumentError, "Unknown value #{value}!") unless mapping[value]

      add_value(mask_column, mapping[value])
    end
  end

  # Return if value presents in mask (raw value)
  def value?(mask_column, val)
    send(mask_column) & val != 0
  end

  def add_value(mask_column, val)
    send("#{mask_column}=", send(mask_column) | val)
  end
end
