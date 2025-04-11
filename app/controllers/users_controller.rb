  class UsersController < ApplicationController
    include Authentication
    include BeanDefinition

    def me
      render json: user_json(current_user), content_type: "application/json"
    end

    def follow_user
      service = friendships_service
      result = service.follow_user(
        follower_id: current_user.id,
        followed_id: params[:id]
      )

      case result
      when :success
        render json: { message: "Followed successfully" }, status: :ok, content_type: "application/json"
      when :already_following
        render json: { message: "Already following" }, status: :ok, content_type: "application/json"
      end
    end

    def un_follow_user
      service = friendships_service
      result = service.unfollow_user(
        follower_id: current_user.id,
        followed_id: params[:id]
      )

      case result
      when :success
        render json: { message: "Unfollowed successfully" }, status: :ok, content_type: "application/json"
      when :not_following
        render json: { message: "You were not following this user" }, status: :ok, content_type: "application/json"
      end
    end

    def following_sleep_records
      page     = (params[:page] || "1").to_i
      per_page = (params[:per_page] || "20").to_i
      sort_str = params[:sort]          # e.g. "duration_asc" or "duration_desc"
      sort_key = sort_str == "duration_asc" ? :duration_asc : :duration_desc

      service  = friendships_service
      result = service.fetch_following_sleep_records(
        user_id: current_user.id,
        sort: sort_key,
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
      }
    end

    def index
      page     = (params[:page] || "1").to_i
      per_page = (params[:per_page] || "20").to_i

      service = users_service
      result = service.list_users(
        page: page,
        per_page: per_page
      )

      render json: {
        meta: {
          page: result[:page],
          per_page: result[:per_page],
          total: result[:total_count]
        },
        data: result[:records].map { |u| user_json(u) }
      }, content_type: "application/json"
    end

    def show
      service = users_service
      result = service.get_user(id: params[:id])

      if result[:user]
        render json: user_json(result[:user]), content_type: "application/json"
      else
        render json: { error: "User not found" }, status: :not_found, content_type: "application/json"
      end
    end

    private

    def sleep_record_json(entity)
      {
        id:         entity.id,
        user_id:    entity.user_id,
        start_time: entity.start_time,
        end_time:   entity.end_time,
        duration:   duration_in_seconds(entity),
        created_at: entity.created_at,
        updated_at: entity.updated_at
      }
    end

    def user_json(entity)
      {
        id: entity.id,
        name: entity.name.value,
        email: entity.email.value,
        created_at: entity.created_at,
        updated_at: entity.updated_at
      }
    end

    def duration_in_seconds(record)
      return nil unless record.end_time
      (record.end_time - record.start_time).to_i
    end
  end

