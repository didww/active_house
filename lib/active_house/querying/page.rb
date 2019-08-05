module ActiveHouse
  module Querying
    module Page
      extend ActiveSupport::Concern

      def initial_values
        super.merge page_number: nil
      end

      def page(page_number)
        dup.page!(page_number)
      end

      def page!(page_number)
        page_number ||= 1
        raise ArgumentError, 'page_number must be >= 1' if page_number < 1

        values[:page_number] = page_number
        self
      end

      def per(page_size)
        page_number = values[:page_number] || 1
        raise ArgumentError, 'page_number must be >= 1' if page_number < 1
        raise ArgumentError, 'page_size must be >= 0' if page_size < 0

        offset = (page_number - 1) * page_size
        records = limit(page_size, offset).to_a
        total_count = count
        Kaminari.paginate_array(records, total_count: total_count).page(page_number).per(page_size)
      end

    end
  end
end
