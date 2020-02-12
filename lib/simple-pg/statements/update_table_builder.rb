# frozen_string_literal: true

require_relative 'clauses/columns_clause'
require_relative 'clauses/set_clause'
require_relative 'clauses/where_clause'

require_relative 'statement'
require_relative 'statement_builder'

module SimplePG
  class UpdateTableStatementBuilder < StatementBuilder
    include ColumnsClause
    include SetClause
    include WhereClause

    def build!
      return statement if statement

      indexer = create_indexer

      where = where_clause(params[:where], indexer: indexer, extract_values: false)
      set = set_clause(params.fetch(:values), indexer: indexer, extract_values: false)
      columns = columns_clause(params[:columns])

      table = params.fetch(:table)
      set_to = set[:set]

      @arguments = extract_clause_values set[:mappings].merge(where[:mappings])

      @statement = Statement.new <<-COMMAND
        UPDATE
          #{table}
        SET
          #{set_to}
        #{where_text(where)}
        RETURNING
          #{columns}
        ;
      COMMAND
    end

  end
end
