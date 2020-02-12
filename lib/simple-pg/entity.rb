# frozen_string_literal: true

module SimplePG
  class Entity
    attr_reader :row

    def initialize(row)
      # Stores the values for this entity
      @row = row
    end

    def [](column)
      @row[column]
    end

    def to_hash
      @row
    end

    def each(&block)
      to_hash.yield(&block)
    end

    def to_json(arg=nil)
      self.to_hash.to_json(arg)
    end

    def fetch(column, default=nil)
      default ? @row.fetch(column) : @row.fetch(column, default)
    end

  end
end
