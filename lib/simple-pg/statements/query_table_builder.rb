# frozen_string_literal: true

require_relative 'clauses/columns_clause'
require_relative 'clauses/order_by_clause'
require_relative 'clauses/where_clause'

require_relative 'statement'
require_relative 'statement_builder'

module SimplePG
  class QueryTableStatementBuilder < StatementBuilder
    include ColumnsClause
    include WhereClause
    include OrderByClause

    def build!
      return statement if statement

      table = params.fetch(:table)

      where = where_clause(params[:where])
      columns = columns_clause(params[:columns])
      order_by = order_by_clause(params[:order_by])

      @arguments = where[:values]

      @statement = Statement.new <<-COMMAND
        SELECT
          #{columns}
        FROM
          #{table}
        #{where_text(where)}
        #{order_by};
      COMMAND
    end

  end
end
