module Thoth
  module Rails
    module ControllerContext

      def self.included(base)
        base.around_action(:set_thoth_request_context)
      end

      def set_thoth_request_context
        Thoth.context = Thoth.context.merge(thoth_request_context)
        yield
        Thoth.clear_context!
      end

      def thoth_request_context
        #>= Rails 4.2
        if ::Rails::VERSION::MAJOR >= 5 || (::Rails::VERSION::MAJOR == 4 && ::Rails::VERSION::MINOR >= 2)
          context = params.to_unsafe_h
        else
          context = params.to_h
        end
        context[:current_user] = current_user.try(:id) if defined?(current_user)
        context
      end
    end
  end
end

if defined?(::ActionController)
  ::ActiveSupport.on_load(:action_controller) { include Thoth::Rails::ControllerContext }
end
