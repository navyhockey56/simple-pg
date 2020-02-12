# frozen_string_literal: true

require_relative '../logging'

module SimplePG
  class StatementBuilder
    attr_reader :params, :statement, :arguments

    def initialize(params)
      @params = params
      @arguments = []
      @statement = nil
    end

    def build!
      raise 'Unimplemented'
    end

    def execute!(db)
      build!

      statement.execute!(db, arguments)
    end
  end
end
