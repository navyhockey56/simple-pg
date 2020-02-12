# frozen_string_literal: true

module SimplePG
  class Column
    module Types
      INTEGER = 'INTEGER'
      SERIAL = 'SERIAL'
      TIMESTAMP = 'TIMESTAMP'

      def self.VARCHAR(length)
        length = length.to_i
        raise 'Length of VARCHAR must be positive' unless length.positive?

        "VARCHAR(#{length})"
      end

      TYPES = [INTEGER, SERIAL, TIMESTAMP]

      def self.valid?(type)
        /VARCHAR\(\d+\)/.match?(type) || TYPES.include?(type)
      end
    end

    module Modifiers
      UNIQUE        = "UNIQUE"
      NOT_NULL      = "NOT NULL"
      PRIMARY_KEY   = "PRIMARY KEY"

      def self.DEFAULT(value)
        "DEFAULT #{value}"
      end

      FUNC_CURRENT_TIME = "current_timestamp"

      MODIFIERS = [UNIQUE, NOT_NULL, PRIMARY_KEY]

      def self.valid?(modifier)
        /DEFAULT \w+/.match?(modifier) || MODIFIERS.include?(modifier)
      end
    end

    module Mappers
      require 'time'

      def self.map_to_time
        -> (time, _options) do
          if time.is_a?(String)
            time.match(/^\d+$/) ? Time.at(time.to_i) : Time.parse(time)
          elsif time.is_a?(Integer)
            Time.at(time)
          elsif time.is_a?(Time)
            time
          else
            raise "Unable to map time: #{time}"
          end
        end
      end
    end

    module Validators
      def self.validate_email!
        -> (email) do
          unless email.match(URI::MailTo::EMAIL_REGEXP)
            raise SimplePG::Exceptions::InvalidColumnValue, "Invalid email format: #{email}"
          end
        end
      end

      def self.validate_phone_number!
        -> (number) do
          raise SimplePG::Exceptions::InvalidColumnValue,'Invalid phone number' unless number.match(/^\d{10}$/)
        end
      end
    end

    attr_reader :name, :type, :modifiers, :mapper, :validators, :default

    def initialize(name:, type:, modifiers: nil, mapper: nil, validators: nil, default: nil)
      raise 'Invalid type' unless Types.valid?(type)

      @type = type
      @modifiers = Array(modifiers).each do |modifier|
        raise 'Invalid modifier' unless Modifiers.valid?(modifier)
      end

      @name = name.to_sym rescue (raise 'Name cannot be nil')
      @mapper = mapper
      @validators = Array(validators)
      @default = default
    end

    def required?
      @_required == true
    end

    def map(value, options = nil)
      value ||= default
      if value.nil?
        raise 'Value is required' if required?
        return nil
      end

      if mapper
        value = mapper.call(value, options)
      else
        case type
        when Types::SERIAL, Types::INTEGER
          value = value ? value.to_i : nil
        when /VARCHAR/
          value = value ? value.to_s : nil
        when Types::TIMESTAMP
          value = value ? Time.parse(value) : nil
        end
      end

      validators.each { |validator| validator.call(value) }

      value
    end
  end
end
