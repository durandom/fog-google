module Fog
  module Compute
    class Google
      class InstanceGroups < Fog::Collection
        model Fog::Compute::Google::InstanceGroup

        def all(filters = {})
          if filters[:zone]
            data = service.list_instance_groups(filters[:zone]).body
          else
            data = []
            service.list_aggregated_instance_groups.body["items"].each_value do |group|
              data.concat(group["instanceGroups"]) if group["instanceGroups"]
            end
          end

          load(data)
        end

        def get(identity, zone = nil)
          if zone.nil?
            zones = service.list_aggregated_instance_groups(:filter => "name eq .*#{identity}").body["items"]
            target_zone = zones.each_value.select { |zone| zone.key?("instanceGroups") }
            response = target_zone.first["instanceGroups"].first unless target_zone.empty?
            zone = response["zone"].split("/")[-1]
          end

          if instance_group = service.get_instance_group(identity, zone).body
            new(instance_group)
          end
        rescue Fog::Errors::NotFound
          nil
        end

        # TODO: To be deprecated
        def add_instance(params)
          Fog::Logger.deprecation(
            "#{self.class}.#{__method__} is deprecated, use Fog::Compute::Google::InstanceGroup.#{__method__} instead [light_black](#{caller.first})[/]"
          )
          params[:instance] = [params[:instance]] unless params[:instance] == Array
          service.add_instance_group_instances(params[:group], params[:zone], params[:instance])
        end

        # TODO: To be deprecated
        def remove_instance(params)
          Fog::Logger.deprecation(
            "#{self.class}.#{__method__} is deprecated, use Fog::Compute::Google::InstanceGroup.#{__method__} instead [light_black](#{caller.first})[/]"
          )
          params[:instance] = [params[:instance]] unless params[:instance] == Array
          service.remove_instance_group_instances(params[:group], params[:zone], params[:instance])
        end
      end
    end
  end
end
