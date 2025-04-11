 class SleepRecordsController < ApplicationController
    include Authentication
    include BeanDefinition

    # GET /sleep_records
    # Returns a (possibly paginated) list of the current user's sleep records.
    def show
      page     = (params[:page] || "1").to_i
      per_page = (params[:per_page] || "20").to_i

      service = sleep_records_service
      result = service.list_records(
        user_id: current_user.id,
        page: page,
        per_page: per_page
      )

      render json: {
        meta: {
          page: result[:page],
          per_page: result[:per_page],
          total: result[:total_count]
        },
        data: result[:records].map { |r| sleep_record_json(r) }
      }, content_type: "application/json"
    end

    # POST /sleep_records
    # "Clock in": creates a new SleepRecord with start_time=now,
    # then returns ALL of the user's SleepRecords in descending order.
    def clock_in
      service = sleep_records_service
      records = service.clock_in(user_id: current_user.id)

      # 201 for newly created
      render json: records.map { |r| sleep_record_json(r) }, status: :created, content_type: "application/json"
    end

    # PATCH /sleep_records/:id
    # "Clock out": updates end_time of an existing SleepRecord for current user
    def clock_out
      service = sleep_records_service
      updated_record = service.clock_out(
        record_id: params[:id],
        user_id: current_user.id
      )

      # 200 OK for a successfully updated resource
      render json: sleep_record_json(updated_record), status: :ok, content_type: "application/json"
    end

    private

    # Utility method to convert a SleepRecord entity to a JSON-friendly hash
    def sleep_record_json(entity)
      {
        id:         entity.id,
        user_id:    entity.user_id,
        start_time: entity.start_time,
        end_time:   entity.end_time,
        duration:   entity.end_time ? (entity.end_time - entity.start_time).to_i : nil,
        created_at: entity.created_at,
        updated_at: entity.updated_at
      }
    end
  end

