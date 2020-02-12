# frozen_string_literal: true

# The errors used by this project
module SimplePG
  module Exceptions
    class DataMasterError < StandardError
    end

    # Raise when an entity cannot be created
    class FailedToCreateEntity < DataMasterError
      def initialize(msg = 'Failed to create Entity')
        super
      end
    end

    # Raise when an entity cannot be udpated.
    class FailedToUpdateEntity < DataMasterError
      def initialze(msg = 'Failed to update an Entity')
        super
      end
    end

    # Raise when an entity cannot be deleted.
    class FailedToDeleteEntity < DataMasterError
      def initialze(msg = 'Failed to delete an Entity')
        super
      end
    end

    class FailedToTransformEntity < DataMasterError
      def initialize(msg = 'Failed to transform the data provided into an Entity')
        super
      end
    end

    class FailedQuery < DataMasterError
      def initialize(msg = 'Failed to perform a query')
        super
      end
    end

    # Raise when an entity cannot be created because doing so would
    # violate a uniqueness constraint on the table.
    class UniqueViolation < StandardError
      def initilize(msg = 'Failed to create/update an Entity due to uniqueness violation')
        super
      end
    end

    # Raise when the data provided to entity initialization is invalid.
    class InvalidEntity < DataMasterError
      def initialize(msg = 'Invalid data provided when attempting to create an Entity')
        super
      end
    end

    # Raise when an argument provided to a method is invalid
    class InvalidArgument < DataMasterError
      def initialize(msg = 'Invalid argument provided.')
        super
      end
    end

    class InvalidColumnValue < DataMasterError
      def initialize(msg = 'An invalid value for a column was provided to an entity.')
        super
      end
    end

    # Raise when someone tries to call a method (etc) that shouldn't
    # be accessed.
    class IllegalAccess < DataMasterError
      def initialize(msg = 'Illegal access attempted.')
        super
      end
    end

    # Raise when someone tries to execute a prepared statement that
    # doesn't exist.
    class PreparedStatementNotDefined < DataMasterError
      def initialize(statement_name)
        super("Could not located prepared statement: #{statement_name}")
      end
    end

  end
end
