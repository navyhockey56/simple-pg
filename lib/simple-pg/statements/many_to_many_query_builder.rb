# frozen_string_literal: true

require_relative 'clauses/column_definitions_clause'


require_relative '../tables/many_to_many'
require_relative 'query_table_builder'

module SimplePG
  class ManyToManyQueryStatementBuilder < QueryTableStatementBuilder

    def build!
      return statement if statement

      id = params.fetch(:id)
      select_table = params.fetch(:select_table)
      search_table = params.fetch(:search_table)

      search_prefix = "#{select_table}."
      @params.fetch(:columns).map! do |column|
        if column.to_s.start_with? search_prefix
          column
        else
          "#{search_prefix}#{column}"
        end
      end
      join_table_name = ManyToMany.table_name(select_table, search_table)

      @params[:table] = "#{select_table}, #{join_table_name}"
      @params[:where] = {
        operator: 'and',
        clauses: [
          {
            column: "#{join_table_name}.#{ManyToMany.column_id(select_table)}",
            static_value: "#{select_table}.id"
          },
          {
            column: "#{join_table_name}.id",
            value: id
          }
        ]
      }

      # Delegate creating the query to the QueryTableStatementBuilder
      super
    end

  end
end
