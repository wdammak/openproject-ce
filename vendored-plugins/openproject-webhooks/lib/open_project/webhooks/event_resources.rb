module OpenProject::Webhooks
  module EventResources
    class << self
      def subscribe!
        resource_modules.each do |handler|
          handler.subscribe!
        end
      end

      ##
      # Return a complete mapping of all resource modules
      # in the form { label => { event1: label , event2: label } }
      def available_events_map
        @available_events ||= Hash[resource_modules.map { |m| [m.resource_name, m.available_events_map] }]
      end

      ##
      # Find a module based on the event name
      def lookup_resource_name(event_name)
        resource = resource_modules.detect { |m| m.available_events_map.key?(event_name) }
        resource.try(:resource_name)
      end

      def resource_modules
        @resource_modules ||= begin
          resources.map do |name|
            begin
              "OpenProject::Webhooks::EventResources::#{name.to_s.camelize}".constantize
            rescue NameError => e
              raise ArgumentError, "Failed to initialize resources module for #{name}: #{e}"
            end
          end
        end
      end

      def resources
        %i(work_package)
      end
    end
  end
end