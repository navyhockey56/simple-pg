# frozen_string_literal: true

# The ColumnsDefinitionsClause is responsible for creating the column definition
# statements in a create table statement.
module SimplePG
  module ColumnDefinitionsClause

    # Produces the column definitions for a create table statement
    # from the provide `columns`.
    #
    # @param [Hash] columns - A hash mapping column name to SimplePG::Column.
    # @return [String] The definitions for the given columns.
    def column_definitions_clause(columns)
       column_definitions = columns.map do |name, column|
          modifiers = Array(column.modifiers).join(' ')

          "#{name} #{column.type} #{modifiers}"
       end

       column_definitions.join(",\n\t")
    end
  end
end
