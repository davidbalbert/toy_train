require 'rack'

module NoFramework
  class Application
    def initialize(&block)
      @routes = Routes.new
      @routes.configure(&block)
    end

    def call(env)
      req = Rack::Request.new(env)
      @routes.dispatch(req)
    end
  end

  NotFoundApp = ->(env) { [404, {}, ["Not found: #{Rack::Request.new(env).path}"]] }

  class Routes
    module NormalizePath
      def normalize(path)
        if path[-1] == '/'
          path[0..-2]
        else
          path
        end
      end
    end

    include NormalizePath

    class DSL
      include NormalizePath

      def initialize(&block)
        @routes = {}
        instance_eval(&block)
      end

      def root(handler)
        get('/', handler)
      end

      def get(path, handler)
        @routes[[normalize(path), 'GET']] = handler
      end

      def post(path, handler)
        @routes[[normalize(path), 'POST']] = handler
      end

      def put(path, handler)
        @routes[[normalize(path), 'PUT']] = handler
      end

      def delete(path, handler)
        @routes[[normalize(path), 'DELETE']] = handler
      end

      def patch(path, handler)
        @routes[[normalize(path), 'PATCH']] = handler
      end

      def to_h
        @routes
      end
    end

    def initialize
      @routes = Hash.new { NotFoundApp }
    end

    def dispatch(req)
      route_for(req).call(req.env)
    end

    def configure(&block)
      add_routes(DSL.new(&block))
    end

    private

    def route_for(req)
      @routes[[normalize(req.path), req.request_method]]
    end

    def add_routes(dsl)
      @routes.merge!(dsl.to_h)
    end
  end
end
