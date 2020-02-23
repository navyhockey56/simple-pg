# frozen_string_literal: true

# The errors used by this project
module SimplePG
  module Exceptions
    class SimplePGError < StandardError
    end

    class InvalidColumnValue < SimplePGError
      def initialize(msg = 'An invalid value for a column was provided to an entity.')
        super
      end
    end
  end
end
