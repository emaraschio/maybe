class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV.fetch("BASIC_AUTH_USER"), password: ENV.fetch("BASIC_AUTH_PASSWORD")
  include Localize, AutoSync, Authentication, Invitable, SelfHostable, StoreLocation
  include Pagy::Backend

  private

    def with_sidebar
      return "turbo_rails/frame" if turbo_frame_request?

      "with_sidebar"
    end
end
