require 'rack'

module Frank
  class Base
    attr_reader :routes, :request

    def initialize
      @routes = {}
    end

    def delete(path, &handler)
      route('DELETE', path, &handler)
    end

    def get(path, &handler)
      route('GET', path, &handler)
    end

    def head(path, &handler)
      route('HEAD', path, &handler)
    end

    def patch(path, &handler)
      route('PATCH', path, &handler)
    end

    def post(path, &handler)
      route('POST', path, &handler)
    end

    def put(path, &handler)
      route('PUT', path, &handler)
    end

    def call(env)
      @request = Rack::Request.new(env)
      verb = request.request_method
      requested_path = request.path_info
      handler = routes.fetch(verb, {}).fetch(requested_path, nil)
      return [404, {}, ["Oops! No route for #{verb} #{requested_path}"]] unless handler
      result = instance_eval(&handler) # So handler can see Frank's context
      return [200, {}, [result]] if result.class == String
      result
    end

    def params
      request.params
    end

    private

    def route(verb, path, &handler)
      routes[verb] ||= {}
      routes[verb][path] = handler
    end
  end

  Application = Base.new

  module Delegator
    def self.delegate(*methods, to:)
      Array(methods).each do |method_name|
        define_method(method_name) do |*args, &block|
          to.send(method_name, *args, &block)
        end

        private method_name
      end
    end

    delegate :get, :patch, :put, :post, :delete, :head, to: Application
  end
end

include Frank::Delegator
