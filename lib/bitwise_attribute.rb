# frozen_string_literal: true

require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext'

require 'bitwise_attribute/version'
require 'bitwise_attribute/values_list'
require 'bitwise_attribute/active_record_methods'

module BitwiseAttribute
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    include BitwiseAttribute::ActiveRecordMethods

    def attr_bitwise(name, column_name: nil, values:)
      column_name ||= "#{name.to_s.singularize}_mask"

      mapping = build_mapping(values)

      define_class_methods(name, column_name, mapping)
      define_instance_methods(name, column_name, mapping)
    end

    private

    def define_class_methods(name, column_name, mapping)
      define_singleton_method(name) do
        mapping
      end

      define_named_scopes(name, column_name, mapping) if defined?(ActiveRecord)
    end

    def define_instance_methods(name, column_name, mapping)
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
    def build_mapping(values)
      {}.tap do |hash|
        values.each_with_index { |key, index| hash[key] = (0b1 << index) }
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

      send("#{mask_column}=", send(mask_column) | mapping[value])
    end
  end

  # Return if value is present in mask (raw value)
  def value?(mask_column, val)
    send(mask_column) & val != 0
  end
end
