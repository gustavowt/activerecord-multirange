# frozen_string_literal: true

module Activerecord
  module Multirange
    module TableDefinition
      def tsmultirange(*args, **options)
        args.each do |name|
          column(name, :tsmultirange, **options)
        end
      end

      def tstzmultirange(*args, **options)
        args.each do |name|
          column(name, :tstzmultirange, **options)
        end
      end

      def datemultirange(*args, **options)
        args.each do |name|
          column(name, :datemultirange, **options)
        end
      end

      def nummultirange(*args, **options)
        args.each do |name|
          column(name, :nummultirange, **options)
        end
      end

      def int8multirange(*args, **options)
        args.each do |name|
          column(name, :int8multirange, **options)
        end
      end

      def int4multirange(*args, **options)
        args.each do |name|
          column(name, :int4multirange, **options)
        end
      end
    end
  end
end
