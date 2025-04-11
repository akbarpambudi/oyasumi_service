module Domain
  module Repository
    class SleepRecordRepository
      def find(id)
        raise NotImplementedError
      end

      def create(entity)
        raise NotImplementedError
      end

      def update(entity)
        raise NotImplementedError
      end

      def find_all_by_user(user_id)
        raise NotImplementedError
      end

      def find_completed_since(user_ids:, since:)
        raise NotImplementedError
      end

      def find_all_by_user_paginated(user_id, page:, per_page:)
        raise NotImplementedError
      end

      def find_completed_since_paginated(user_ids:, since:, page:, per_page:, sort: :duration_desc)
        raise NotImplementedError
      end
    end
  end
end
