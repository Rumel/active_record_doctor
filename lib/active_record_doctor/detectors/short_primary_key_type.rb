# frozen_string_literal: true

require "active_record_doctor/detectors/base"

module ActiveRecordDoctor
  module Detectors
    class ShortPrimaryKeyType < Base # :nodoc:
      @description = "detect primary keys with short integer types"
      @config = {
        ignore_tables: {
          description: "tables whose primary keys should not be checked",
          global: true
        }
      }

      private

      def message(table:, column:)
        "change the type of #{table}.#{column} to bigint"
      end

      def detect
        each_table(except: config(:ignore_tables)) do |table|
          column = primary_key(table)
          next if column.nil?
          next if bigint?(column) || uuid?(column)

          problem!(table: table, column: column.name)
        end
      end

      def bigint?(column)
        if column.respond_to?(:bigint?)
          column.bigint?
        else
          /\Abigint\b/.match?(column.sql_type)
        end
      end

      def uuid?(column)
        column.sql_type == "uuid"
      end
    end
  end
end
