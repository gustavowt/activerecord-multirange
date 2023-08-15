# frozen_string_literal: true

module Activerecord
  module Multirange
    module SchemaStatements
      def native_database_types
        super.merge({
                      tsmultirange: { name: "tsmultirange" },
                      datemultirange: { name: "datemultirange" },
                      tstzmultirange: { name: "tstzmultirange" },
                      nummultirange: { name: "nummultirange" },
                      int8multirange: { name: "int8multirange" },
                      int4multirange: { name: "int4multirange" }
                    })
      end
    end
  end
end
