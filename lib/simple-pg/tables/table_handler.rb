# frozen_string_literal: true

require_relative '../handler'
require_relative 'join_table'
require_relative 'many_to_many'

module SimplePG
  class TableHandler

    attr_reader :table, :handler
    attr_accessor :default_order_by

    def initialize(table, many_to_many_relationships = nil)
      @table = table
      @handler = Handler.new

      # Make sure the table exists
      create_table(table)

      # Create join tables for the many to many relationships
      @many_to_many_relationships = {}
      Array(many_to_many_relationships).uniq.each do |other_table|
        # Create the table definition
        many_to_many_table = ManyToMany.table_definition(table.name, other_table)
        # Store the table definition
        @many_to_many_relationships[other_table] = many_to_many_table
        # Create the join table
        create_table(many_to_many_table)
      end
    end

    def create_table(table)
      handler.create_table(table)
    end

    def drop_table
      handler.drop_table(table.name)
    end

    def create_entity(values, columns: nil)
      # Map the values to the proper types
      entity = table.transform(values) if values.is_a?(Hash)
      entity = values if values.is_a?(Entity)
      raise "Invalid entity type provided: #{values.class}" unless entity

      # Default to all columns if none are provided
      columns ||= table.column_names

      # Create the entity
      hash_entity = handler.create_entity(
        table: table.name,
        values: entity.to_hash,
        columns: table.column_names,
        transformation: 'hash'
      )

      table.transform(hash_entity, columns: columns)
    end

    def query(columns: nil, where: nil, order_by: default_order_by)
      columns ||= table.column_names

      results = handler.query(
        table: table.name,
        columns: columns,
        where: where,
        order_by: order_by,
        transformation: 'hash'
      )

      results.map { |result| table.transform(result, columns: columns) }
    end

    def query_column(column:, value:, operator: '=', columns: nil, order_by: nil)
      query(
        columns: columns,
        where: { operator: operator, column: column, value: value },
        order_by: order_by
      )
    end

    def query_by_id(id)
      query_column(
        column: 'id',
        value: id
      ).first
    end

    def update(values:, columns: nil, where: nil)
      columns ||= table.column_names

      # Convert all columns to the proper types
      values.each do |column, value|
        values[column] = table[column].map(value)
      end

      results = handler.update(
        table: table.name,
        values: values,
        columns: columns,
        where: where,
        transformation: 'hash'
      )

      results.map { |result| table.transform(result, columns: columns) }
    end

    def update_column(column:, value:, where: nil)
      update(
        values: { column.to_sym => value },
        where: where
      )
    end

    def update_column_by_column(update:, value:, search:, term:, operator: '=')
      update_column(
        column: update,
        value: value,
        where: { column: search, value: term, operator: operator }
      )
    end

    def update_column_by_id(id:, column:, value:)
      update_column_by_column(
        update: column,
        value: value,
        search: 'id',
        term: id
      ).first
    end

    def delete(where:, columns: nil)
      columns ||= table.column_names

      results = handler.delete(
        table: table.name,
        where: where,
        columns: columns,
        transformation: 'hash'
      )

      results.map { |result| table.transform(result, columns: columns) }
    end

    def delete_by_column(column:, value:, operator: '=')
      delete(
        where: { column: column, value: value, operator: operator }
      )
    end

    def delete_by_id(id)
      delete_by_column(
        column: 'id',
        value: id
      ).first
    end

    def join_many_to_many(other_table, id, transformation: 'hash', columns: nil)
      raise "No relationship to #{other_table.name} found." unless @many_to_many_relationships[other_table.name]

      results = handler.join_many_to_many(
        select: other_table.name,
        columns: columns || other_table.column_names,
        search: table.name,
        id: id,
        transformation: transformation
      )
      return results unless transformation == 'hash'

      results.map { |result| other_table.transform(result[other_table.name.to_sym]) }
    end

    def join(options)
      join_table = options[:join_table]
      table = options[:table]
      raise 'You must provide a table to join with or a pre-existing join table' unless join_table || table

      join_table ||= JoinTable.new([self.table, table])
      transformation = options.fetch(:transformation, 'hash')

      results = handler.query(
        table: join_table.name,
        columns: options[:columns],
        where: options.fetch(:where),
        order_by: options.fetch(:order_by, default_order_by),
        transformation: transformation
      )
      return results unless transformation == 'hash'

      results.map do |result|
        join_table.transform(result,
          flatten_tables: options.fetch(:flatten_tables, self.table.name),
          flatten: options[:flatten]
        )
      end
    end

    def join_on_foreign_key(options)
      options[:where] = {
        operator: '&',
        clauses: [
          options[:where],
          {
            column: options.fetch(:key),
            static_value: options.fetch(:foreign_key)
          }
        ]
      }

      join(options)
    end

    def join_on_foreign_key_by_column(options)
      options[:where] = {
        operator: options.fetch(:operator, '='),
        column: options.fetch(:column),
        value: options.fetch(:value)
      }

      join_on_foreign_key(options)
    end

    def join_on_foreign_column_by_id(options)
      options[:column] = "#{table.name}.id"
      options[:value] = options.fetch(:id)

      join_on_foreign_key_by_column(options)
    end

  end
end
