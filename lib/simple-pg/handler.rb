# frozen_string_literal: true

require_relative 'statements/create_entity_builder'
require_relative 'statements/create_table_builder'
require_relative 'statements/delete_from_table_builder'
require_relative 'statements/drop_table_builder'
require_relative 'statements/many_to_many_query_builder'
require_relative 'statements/query_table_builder'
require_relative 'statements/trigger_updated_at_builder'
require_relative 'statements/update_table_builder'

require_relative 'entity'
require_relative 'postgres_connector'

module SimplePG
  class Handler

    def db
      @_db ||= PostgresqlConnector.new
    end

    def create_table(table)
      CreateTableStatementBuilder.new(
        table: table
      ).execute!(db)

      TriggerUpdatedAtStatementBuilder.new(
        table: table.name
      ).execute!(db)

      nil
    rescue PG::DuplicateObject
      # This is catching a duplicate trigger.
      # TODO: Query for triggers in the system and check if
      # the trigger already exists.
      nil
    end

    def drop_table(table_name)
      DropTableStatementBuilder.new(
        table: table_name,
      ).execute!(db)
    end

    def create_entity(table:, values:, columns:, transformation: nil)
      result = CreateEntityStatementBuilder.new(
        table: table,
        values: values,
        columns: columns
      ).execute!(db)

      transform(result.values, columns, transformation).first
    end

    def query(table:, columns:, where: nil, order_by: nil, transformation: nil)
     result = QueryTableStatementBuilder.new(
        table: table,
        columns: columns,
        where: where,
        order_by: order_by
      ).execute!(db)

     transform(result.values, columns, transformation)
    end

    def update(table:, values:, columns:, where: nil, transformation: nil)
      result = UpdateTableStatementBuilder.new(
        table: table,
        values: values,
        columns: columns,
        where: where
      ).execute!(db)

      transform(result.values, columns, transformation)
    end

    def delete(table:, where:, columns:, transformation: nil)
      result = DeleteFromTableStatementBuilder.new(
        table: table,
        where: where,
        columns: columns
      ).execute!(db)

      transform(result.values, columns, transformation)
    end

    def join_many_to_many(select:, columns:, search:, id:, transformation: nil)
      result = ManyToManyQueryStatementBuilder.new(
        select_table: select,
        columns: columns,
        search_table: search,
        id: id
      ).execute!(db)

      transform(result.values, columns, transformation)
    end

    def raw_to_hash(raw_results, columns)
      # Map each raw entity to an instance of the Entity object
      raw_results.map do |result|
        # map the columns into a hash
        hash_entity = {}
        columns.each_with_index do |column_name, index|

          unless (pieces = column_name.to_s.split('.')).empty?
            section_to_set = hash_entity
            stop_at = pieces.length - 1
            pieces.each_with_index do |piece, piece_index|
              if piece_index == stop_at
                section_to_set[piece.to_sym] = result[index]
              else
                section_to_set[piece.to_sym] ||= {}
                section_to_set = section_to_set[piece.to_sym]
              end
            end
          else
            hash_entity[column_name.to_sym] = result[index]
          end
        end

        hash_entity
      end
    end

    def transform(raw_results, columns, transformation)
      if transformation.to_s.casecmp('hash').zero?
        raw_to_hash(raw_results, columns)
      else
        raw_results
      end
    end

  end
end
