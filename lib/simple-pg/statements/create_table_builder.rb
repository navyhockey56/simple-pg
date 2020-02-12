# frozen_string_literal: true

require_relative 'clauses/column_definitions_clause'

require_relative 'statement'
require_relative 'statement_builder'

module SimplePG
  class CreateTableStatementBuilder < StatementBuilder
    include ColumnDefinitionsClause

    def build!
      return statement if statement

      table = params.fetch(:table)
      columns_definitions = column_definitions_clause(table.columns)

      @statement = Statement.new <<-COMMAND
        CREATE TABLE IF NOT EXISTS #{table.name} (
          #{columns_definitions}
        )
      COMMAND
    end
  end
end
