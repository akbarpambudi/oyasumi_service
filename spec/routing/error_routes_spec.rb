require 'rails_helper'

RSpec.describe 'Error Routes', type: :routing do
  describe 'Error handling routes' do
    it 'routes /404 to errors#not_found' do
      expect(get: '/404').to route_to('errors#not_found')
    end

    it 'routes /500 to errors#internal_server_error' do
      expect(get: '/500').to route_to('errors#internal_server_error')
    end

    it 'routes invalid paths to errors#not_found' do
      expect(get: '/invalid/path').to route_to(
        controller: 'errors',
        action: 'not_found',
        path: 'invalid/path'
      )
    end

    it 'routes invalid paths with different HTTP methods to errors#not_found' do
      expect(post: '/invalid/path').to route_to(
        controller: 'errors',
        action: 'not_found',
        path: 'invalid/path'
      )
      expect(put: '/invalid/path').to route_to(
        controller: 'errors',
        action: 'not_found',
        path: 'invalid/path'
      )
      expect(patch: '/invalid/path').to route_to(
        controller: 'errors',
        action: 'not_found',
        path: 'invalid/path'
      )
      expect(delete: '/invalid/path').to route_to(
        controller: 'errors',
        action: 'not_found',
        path: 'invalid/path'
      )
    end

    describe 'Special cases' do
      it 'handles paths with special characters' do
        expect(get: '/path/with/special@chars').to route_to(
          controller: 'errors',
          action: 'not_found',
          path: 'path/with/special@chars'
        )
      end

      it 'handles paths with spaces' do
        expect(get: '/path/with%20spaces').to route_to(
          controller: 'errors',
          action: 'not_found',
          path: 'path/with spaces'
        )
      end

      it 'handles paths with query parameters' do
        expect(get: '/invalid/path?param=value').to route_to(
          controller: 'errors',
          action: 'not_found',
          path: 'invalid/path',
          param: 'value'
        )
      end

      it 'handles paths with multiple segments' do
        expect(get: '/very/long/path/with/many/segments').to route_to(
          controller: 'errors',
          action: 'not_found',
          path: 'very/long/path/with/many/segments'
        )
      end
    end

    describe 'Edge cases' do
      it 'routes root path to hello#index' do
        expect(get: '/').to route_to('hello#index')
      end

      it 'handles paths with trailing slashes' do
        expect(get: '/invalid/path/').to route_to(
          controller: 'errors',
          action: 'not_found',
          path: 'invalid/path'
        )
      end

      it 'handles paths with multiple consecutive slashes' do
        expect(get: '/invalid//path').to route_to(
          controller: 'errors',
          action: 'not_found',
          path: 'invalid/path'
        )
      end
    end
  end
end 