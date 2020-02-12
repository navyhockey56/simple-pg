# frozen_string_literal: true

require_relative 'column'
require_relative '../entity'

module SimplePG
  class Table

    attr_reader :name, :column_names, :full_column_names

    def initialize(name, columns)
      @name = name
      if columns.is_a? Array
        @columns = columns.each_with_object({}) do |column, hash|
          #hash["#{name}.#{column.name}".to_sym] = column
          hash[column.name] = column
        end
      elsif columns.is_a? Hash
        @columns = columns
      else
        raise "Unsupported column definitions. Expected Array or Hash, got #{columns.class}"
      end

      # Set the default columns
      Table.default_columns.each { |column| @columns[column.name] = column }

      # Store the column names for quick access / constant sort
      @column_names = @columns.keys.sort
      @full_column_names = @column_names.map { |c| "#{name}.#{c}" }
    end

    def [](column_name)
      columns[column_name.to_sym]
    end

    def fetch_columns(*column_names)
      column_names.map { |column| self[column] }
    end

    def columns
      @columns.dup
    end

    def transform(entity_hash, columns: nil)
      if columns
        columns = columns.each_with_object({}) do |column, columns|
          if column.is_a?(Column)
            columns[column.name] = column
          else
            columns[column.to_sym] = self[column]
          end
        end
      end
      columns ||= @columns

      row = {}
      columns.each do |column_name, column|
        value = entity_hash.fetch(column_name, column.default)
        value ||= entity_hash["#{name}.#{column_name}".to_sym]

        row[column_name] = column.map(value, entity_hash)
      end

      Entity.new(row)
    end

    class << self
      def id_column
        @_id_column ||= Column.new(
          name: 'id',
          type: Column::Types::SERIAL,
          modifiers: [
            Column::Modifiers::PRIMARY_KEY,
            Column::Modifiers::UNIQUE,
            Column::Modifiers::NOT_NULL
          ]
        )
      end

      def created_at_column
        @_created_at_column ||= Column.new(
          name: 'created_at',
          type: Column::Types::TIMESTAMP,
          modifiers: Column::Modifiers.DEFAULT(Column::Modifiers::FUNC_CURRENT_TIME),
          mapper: Column::Mappers.map_to_time
        )
      end

      def updated_at_column
        @_updated_at_column ||= Column.new(
          name: 'updated_at',
          type: Column::Types::TIMESTAMP,
          modifiers: Column::Modifiers.DEFAULT(Column::Modifiers::FUNC_CURRENT_TIME),
          mapper: Column::Mappers.map_to_time
        )
      end

      def default_columns
        @_default_columns ||= [ id_column, created_at_column, updated_at_column ]
      end
    end
  end
end
