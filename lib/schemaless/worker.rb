module Schemaless
  #
  # Do the twist!
  #
  module Worker
    # Module class methods
    class << self

      #
      # Run Schemaless live mode
      #
      def run!
        ::Rails.application.eager_load!
        ::ActiveRecord::Base.descendants.each(&:reset_column_information)
        all_tables.each(&:run!)
        ::ActiveRecord::Base.descendants.each(&:reset_column_information)
      end

      #
      # Run Schemaless migrations
      #
      # ::Rails::Generators
      #   .invoke('schemaless:migration', data, file_name: 'fu',
      #           behavior: :invoke, destination_root: Rails.root)
      def generate!
        ::ActiveRecord::Base.establish_connection 'production'
        all_tables.each do |table|
          next unless table.migrate?
          Schemaless::MigrationGenerator.new([table]).invoke_all
        end
      end

      #
      # Work!
      #
      def all_tables # (models)
        tables = []
        models = ::ActiveRecord::Base.descendants
        fail 'No models...eager load off?' if models.empty?
        models.each do |model|
          next if model.to_s =~ /ActiveRecord::/
          model.reset_column_information
          tables << ::Schemaless::Table.new(model)
        end
        tables
      end
    end # self
  end # Worker
end # Schemaless
