# frozen_string_literal: true

module Activerecord
  module Multirange
    module SchemaStatements
      def native_database_types
        super.merge(Activerecord::Multirange::MULTIRANGE_TYPES)
      end
    end
  end
end
