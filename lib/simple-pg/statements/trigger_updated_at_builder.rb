# frozen_string_literal: true

require_relative 'clauses/column_definitions_clause'

require_relative 'statement'
require_relative 'statement_builder'

module SimplePG
  class TriggerUpdatedAtStatementBuilder < StatementBuilder

    def build!
      return statement if statement

      table = params.fetch(:table)

      @statement = Statement.new <<-COMMAND
        CREATE TRIGGER
          trigger_#{table}_updated_at_column_update
        BEFORE UPDATE ON
          #{table}
        FOR EACH ROW EXECUTE PROCEDURE
          update_updated_at_column();
      COMMAND
    end
  end
end
