# frozen_string_literal: true

# require_relative 'column'
require_relative '../entity'

module SimplePG
  class JoinTable # < Table

    attr_reader :name, :tables

    def initialize(*tables)
      @tables = tables
      @name = tables.map(&:name).sort.join(', ')
    end

    def transform(hash_entity, flatten_tables: nil, flatten: false)
      flatten_tables ||= Array(flatten_tables)
      joined_entity = {}
      tables.each do |table|
        hash = hash_entity[table.name.to_sym]
        next unless hash

        entity = table.transform(hash, columns: hash.keys)
        if flatten || flatten_tables.include?(table.name)
          joined_entity.merge!(entity.to_hash)
        else
          joined_entity[table.name.to_sym] = entity.to_hash
        end
      end

      Entity.new(joined_entity)
    end

  end
end
