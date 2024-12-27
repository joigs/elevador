ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    class ActionDispatch::IntegrationTest
      def log_in_as(user, password: '123456')
        post new_session_path, params: { login: user.username, password: password }
        follow_redirect! # Sigue la redirección si es necesario
      end
    end


  end


end
