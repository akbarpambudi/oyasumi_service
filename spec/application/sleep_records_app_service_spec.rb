require 'rails_helper'

RSpec.describe Application::SleepRecordsAppService, type: :service do
  let(:sleep_record_repository) { instance_double(Domain::Repository::SleepRecordRepository) }
  subject(:sleep_records_app_service) { described_class.new(sleep_record_repository) }

  let(:fixed_time) { Time.utc(2024, 4, 1, 12, 0, 0) }

  before do
    allow(Time).to receive(:current).and_return(fixed_time)
  end

  describe '#clock_in' do
    let(:user_id) { 1 }
    let(:sleep_record) do
      instance_double(
        Domain::Entities::SleepRecord,
        id: 1,
        user_id: user_id,
        start_time: fixed_time,
        end_time: nil
      )
    end

    before do
      allow(sleep_record_repository).to receive(:create)
        .and_return(sleep_record)
      allow(sleep_record_repository).to receive(:find_all_by_user)
        .with(user_id)
        .and_return([sleep_record])
    end

    it 'creates a new sleep record and returns all records' do
      result = sleep_records_app_service.clock_in(user_id: user_id)

      expect(result).to eq([sleep_record])
      expect(sleep_record_repository).to have_received(:create)
      expect(sleep_record_repository).to have_received(:find_all_by_user)
        .with(user_id)
    end
  end

  describe '#clock_out' do
    let(:record_id) { 1 }
    let(:user_id) { 1 }
    let(:sleep_record) do
      instance_double(
        Domain::Entities::SleepRecord,
        id: record_id,
        user_id: user_id,
        start_time: fixed_time - 1.hour,
        end_time: nil
      )
    end

    before do
      allow(sleep_record_repository).to receive(:find)
        .with(record_id)
        .and_return(sleep_record)
      allow(sleep_record_repository).to receive(:update)
        .with(sleep_record)
        .and_return(sleep_record)
      allow(sleep_record).to receive(:end_time=).with(fixed_time)
    end

    it 'updates the sleep record end time' do
      result = sleep_records_app_service.clock_out(record_id: record_id, user_id: user_id)

      expect(result).to eq(sleep_record)
      expect(sleep_record_repository).to have_received(:find)
        .with(record_id)
      expect(sleep_record_repository).to have_received(:update)
        .with(sleep_record)
      expect(sleep_record).to have_received(:end_time=)
        .with(fixed_time)
    end

    context 'when sleep record is not found' do
      before do
        allow(sleep_record_repository).to receive(:find)
          .with(record_id)
          .and_return(nil)
      end

      it 'raises SleepRecordNotFoundError' do
        expect {
          sleep_records_app_service.clock_out(record_id: record_id, user_id: user_id)
        }.to raise_error(Domain::Errors::SleepRecordNotFoundError)
      end
    end

    context 'when user is not the owner' do
      let(:other_user_id) { 2 }

      it 'raises AccessDeniedError' do
        expect {
          sleep_records_app_service.clock_out(record_id: record_id, user_id: other_user_id)
        }.to raise_error(Domain::Errors::AccessDeniedError)
      end
    end
  end

  describe '#list_records' do
    let(:user_id) { 1 }
    let(:page) { 1 }
    let(:per_page) { 20 }
    let(:sleep_record) do
      instance_double(
        Domain::Entities::SleepRecord,
        id: 1,
        user_id: user_id,
        start_time: fixed_time,
        end_time: nil
      )
    end

    before do
      allow(sleep_record_repository).to receive(:find_all_by_user_paginated)
        .with(user_id, page: page, per_page: per_page)
        .and_return([[sleep_record], 1])
    end

    it 'returns paginated sleep records' do
      result = sleep_records_app_service.list_records(
        user_id: user_id,
        page: page,
        per_page: per_page
      )

      expect(result).to eq({
        page: page,
        per_page: per_page,
        total_count: 1,
        records: [sleep_record]
      })

      expect(sleep_record_repository).to have_received(:find_all_by_user_paginated)
        .with(user_id, page: page, per_page: per_page)
    end
  end
end 