# frozen_string_literal: true

# The ColumnsClause is responsible for creating the column reference statements
# in SELECT, UPDATE, DELETE etc calls.
module SimplePG
  module ColumnsClause

    # Creates the subsection for referencing the given column names in a statement
    #
    # @param [Array] columns - The names of the columns to reference
    # @return [String] The subsection for referencing the given columns.
    def columns_clause(columns)
       columns = Array(columns)
       columns.empty? ? '*' : Array(columns).join(', ')
    end

  end
end
