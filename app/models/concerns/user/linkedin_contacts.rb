module Concerns
  module User
    module LinkedinContacts
      extend ActiveSupport::Concern

      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods
      end

      module InstanceMethods
        def import_linkedin_contacts
        end
      end

    end
  end
end
