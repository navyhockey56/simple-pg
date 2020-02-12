# frozen_string_literal: true

require_relative 'clauses/columns_clause'
require_relative 'clauses/values_clause'

require_relative 'statement'
require_relative 'statement_builder'

module SimplePG
  class CreateEntityStatementBuilder < StatementBuilder
    include ColumnsClause
    include ValuesClause

    def build!
      return statement if statement

      table = params.fetch(:table)

      values = values_clause(params.fetch(:values))
      columns_to_return = columns_clause(params[:columns])

      columns_to_set = columns_clause(values[:columns])
      index_values = values[:index_values]

      @arguments = values[:values]

      @statement = Statement.new <<-COMMAND
        INSERT INTO #{table} (
          #{columns_to_set}
        ) VALUES (
          #{index_values}
        ) RETURNING
          #{columns_to_return};
      COMMAND
    end

  end
end
