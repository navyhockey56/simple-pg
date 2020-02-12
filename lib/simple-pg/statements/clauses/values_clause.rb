# frozen_string_literal: true

require_relative 'clause'

module SimplePG
  module ValuesClause
    include Clause

    def values_clause(values)
      indexer = create_indexer
      columns_to_set = []
      index_values = []
      extracted_values = []

      Array(values).each do |column, value|
        next if value.nil?

        index = indexer.call
        columns_to_set << column
        index_values << "$#{index}"
        extracted_values << value
      end

      {
        columns: columns_to_set.join(', '),
        index_values: index_values.join(', '),
        values: extracted_values
      }
    end

  end
end
