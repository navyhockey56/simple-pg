# frozen_string_literal: true

module SimplePG
  module OrderByClause

    def order_by_clause(column)
      column.to_s.empty? ? '' : "ORDER BY #{column}"
    end

  end
end
