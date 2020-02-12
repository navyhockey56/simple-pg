# frozen_string_literal: true

require_relative 'statement'
require_relative 'statement_builder'

module SimplePG
  class DropTableStatementBuilder < StatementBuilder
    def build!
      @statement ||= Statement.new "DROP TABLE #{params.fetch(:table)};"
    end
  end
end
