# frozen_string_literal: true

require_relative 'clause'

module SimplePG
  module WhereClause
    include Clause

    def where_clause(clause, indexer: create_indexer, extract_values: true)
      return { values: [], where: nil, mappings: {} } if clause.nil?

      # Create the where clause
      where = create_where_clause(clause, indexer)
      # Extract values if specified
      where[:values] = extract_clause_values(where[:mappings]) if extract_values
      # Return clause
      where
    end

    def where_text(where_clause)
      where_clause[:where] ? "WHERE\n\t#{where_clause[:where]}" : ''
    end

    private

    def create_where_clause(clause, indexer)
      case clause[:operator].to_s.downcase
      when 'and', '&', '&&'
        create_chained_clause(clause, 'AND', indexer)
      when 'or', '|', '||'
        create_chained_clause(clause, 'OR', indexer)
      when 'like', '~='
        create_simple_clause(clause, 'LIKE', indexer)
      when '>'
        create_simple_clause(clause, '>', indexer)
      when '>='
        create_simple_clause(clause, '>=', indexer)
      when '<='
        create_simple_clause(clause, '<=', indexer)
      when '<'
        create_simple_clause(clause, '<', indexer)
      when '', '=', 'eq', '==', 'equal'
        create_simple_clause(clause, '=', indexer)
      when '!=', 'neq', '<>'
        create_simple_clause(clause, '!=', indexer)
      when 'in', 'contains'
        create_simple_clause(clause, 'IN', indexer)
      when 'between', '><'
        create_between_clause(clause, indexer)
      when 'not', '!'
        create_not_clause(clause, indexer)
      when 'null', '()'
        create_is_clause(clause, 'NULL')
      when 'not null', '!null', '!()'
        create_is_clause(clause, 'NOT NULL')
      else
        raise "Invalid operator: #{clause[:operator]}"
      end
    end

    def create_simple_clause(clause, operation, indexer)
      if clause[:value]
        index = indexer.call
        column = clause.fetch(:column)
        where = "(#{column} #{operation} $#{index})"
        identifier = "#{operation} #{column}"

        {
          where: where,
          mappings: { index => clause.fetch(:value) }
        }
      elsif clause[:static_value]
        column = clause.fetch(:column)
        where = "(#{column} #{operation} #{clause[:static_value]})"
        identifier = "#{operation} #{column}"

        {
          where: where,
          mappings: {}
        }
      end
    end

    def create_is_clause(clause, operation)
      column = clause.fetch(:column)
      {
        where: "(#{column} IS #{operation})",
        mappings: {}
      }
    end

    def create_between_clause(clause, indexer)
      index1, index2 = [indexer.call, indexer.call]
      column = clause.fetch(:column)

      where = "(#{column} BETWEEN $#{index1} AND $#{index2})"

      {
        where: where,
        mappings: {
          index1 => clause.fetch(:start),
          index2 => clause.fetch(:end)
        }
      }
    end

    def create_chained_clause(clause, operation, indexer)
      clauses = clause.fetch(:clauses).map { |c| create_where_clause(c, indexer) }

      # Create the operation
      where = "(#{ clauses.map { |c| c[:where] }.join(" #{operation} ") })"

      # Merge all the mappings together
      mappings = clauses.each_with_object({}) do |clause, all_mappings|
        all_mappings.merge!(clause[:mappings])
      end

      {
        where: where,
        mappings: mappings
      }
    end

  end
end
