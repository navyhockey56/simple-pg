# frozen_string_literal: true

require_relative '../logging'

module SimplePG
  class Statement
    attr_reader :raw_statement, :statement_hash, :statement_name

    def initialize(raw_statement)
      @raw_statement = raw_statement
      @statement_hash = raw_statement.hash
      @statement_name = statements_map[@statement_hash]
    end

    def compile!(db)
      return if prepared?

      @statement_name = store_statement_name statement_hash

      SimplePG.log.debug "Preparing: #{statement_name}\n#{raw_statement}"
      db.prepare_statement statement_name, raw_statement
    end

    def execute!(db, arguments = [])
      compile!(db)

      db.execute_prepared_statement statement_name, Array(arguments)
    end

    def prepared?
      !statement_name.nil?
    end

    private

    def fetch_statement_name(name)
      statements_map[name]
    end

    def store_statement_name(name)
      statements_map[name] = next_statement_name
    end

    def statements_map
      @@_statements_map ||= {}
    end

    def next_statement_name
      @@_counter ||= create_counter
      "statement_#{@@_counter.call}"
    end

    def create_counter
      count = 0
      return (-> () { count += 1 })
    end
  end
end
