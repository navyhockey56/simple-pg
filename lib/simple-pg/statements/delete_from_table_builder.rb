# frozen_string_literal: true

require_relative 'clauses/columns_clause'
require_relative 'clauses/where_clause'

require_relative 'statement'
require_relative 'statement_builder'

module SimplePG
  class DeleteFromTableStatementBuilder < StatementBuilder
    include ColumnsClause
    include WhereClause

    def build!
      return statement if statement

      where = where_clause(params.fetch(:where))
      columns = columns_clause(params[:columns])

      table = params.fetch(:table)

      @arguments = where[:values]

      @statement = Statement.new <<-COMMAND
        DELETE FROM
          #{table}
        WHERE
          #{where[:where]}
        RETURNING
          #{columns};
      COMMAND
    end

  end
end
