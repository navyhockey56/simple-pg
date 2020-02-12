# frozen_string_literal: true

require_relative 'clause'

module SimplePG
  module SetClause
    include Clause

    def set_clause(values, indexer: create_indexer, extract_values: true)
      set = []

      if extract_values
        extracted_values = []
      else
        mappings = {}
      end

      values.each do |column, value|
        index = indexer.call
        set << "#{column} = $#{index}"
        if extract_values
          extracted_values << value
        else
          mappings[index] = value
        end
      end

      set_clause = { set: set.join(', ') }
      if extract_values
        set_clause[:values] = extracted_values
      else
        set_clause[:mappings] = mappings
      end

      set_clause
    end

  end
end
