# frozen_string_literal: true

# A Clause is responsible for defining a piece of a SQL statement.
module SimplePG
  module Clause

    # Creates a lambda that auto-increments by one
    # and returns the index provided.
    #
    # @param [Integer] index - Defines the lower bound (non-inclusive) of the counter
    # @return [Lambda () -> Integer] A lambda that when called, produces the next integer in the sequence.
    def create_indexer(index = 0)
      -> () { index += 1 }
    end

    # Extracts the values from the mappings into an
    # array within the order specified by the keys of
    # the mappings.
    #
    # Mappings = { 1: "foo", 2: 5, 3: "blah" }
    # => ["foo", 5, "blah"]
    #
    # @param [Hash] mappings - The values to extract, keyed by their order.
    # @return [Array] The extracted values, in the order specified by their keys.
    def extract_clause_values(mappings)
      extracted_values = []
      mappings.each do |index, value|
        extracted_values[index - 1] = value
      end

      extracted_values
    end

  end
end
