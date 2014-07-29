module Pipedrive
  module Operations
    module Read
      extend ActiveSupport::Concern
      include ::Enumerable

      # This method smells of :reek:TooManyStatements but ignores them
      def each(params = {})
        return to_enum(:each, params) unless block_given?
        start = params[:start] || 0
        loop do
          res = chunk(params.merge(start: start))
          break if !res.try(:data) || !res.success?
          res.data.each do |item|
            yield item
          end
          break unless res.try(:additional_data).try(:pagination).try(:more_items_in_collection?)
          start = res.try(:additional_data).try(:pagination).try(:next_start)
        end
      end

      def all(params = {})
        each(params).to_a
      end

      def chunk(params = {})
        res = make_api_call(:get, params)
        return [] unless res.success?
        res
      end

      def find_by_id(id)
        make_api_call(:get, id)
      end
    end
  end
end
