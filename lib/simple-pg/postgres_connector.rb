# frozen_string_literal: true

require 'pg'

# require_relative 'exceptions'

module SimplePG
  class PostgresqlConnector

    @@prepared_static_statements = false

    def initialize
      # Execute any global statements
      execute_static_statements!
    end

    def prepare_statement(name, command)
      lock.synchronize {
        connection.prepare name, command
      }
    end

    def execute_prepared_statement(name, arguments=[])
      lock.synchronize {
        connection.exec_prepared name, arguments
      }
    end

    def self.shut_down
      return unless @@connection ||= nil
      @@connection.close
    end

    private

    # The connection to the postgresql database
    #
    # @return [PG::Connection] The connection
    def connection
      @@connection ||= PG.connect(
        dbname: ENV['POSTGRESQL_DB_NAME'],
        user: ENV['POSTGRESQL_USERNAME'],
        password: ENV['POSTGRESQL_USER_PASSWORD']
      )
    end

    def lock
      @@lock ||= Mutex.new
    end

    def execute_static_statements!
      unless @@prepared_static_statements
        # This handles automatically updating the updated_at column (in conjunction with the trigger code below)
        connection.exec <<-COMMAND
          CREATE OR REPLACE FUNCTION update_updated_at_column()
          RETURNS TRIGGER AS $$
          BEGIN
            NEW.updated_at = now();
            RETURN NEW;
          END;
          $$ language 'plpgsql';
        COMMAND
      end
    end

  end
end
