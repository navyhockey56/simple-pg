# frozen_string_literal: true

require_relative 'column'
require_relative 'table'

module SimplePG
  module ManyToMany
    class << self

      def table_name(table1, table2)
        [table1.to_s, table2.to_s].sort.join('__')
      end

      def column_id(table)
        "#{table}_id"
      end

      def table_definition(table1, table2)
        Table.new(table_name(table1, table2), [
          Column.new(
            name: column_id(table1),
            type: Column::Types::INTEGER,
            modifiers: Column::Modifiers::NOT_NULL
          ),
          Column.new(
            name: column_id(table2),
            type: Column::Types::INTEGER,
            modifiers: Column::Modifiers::NOT_NULL
          )
        ])
      end

    end
  end
end
