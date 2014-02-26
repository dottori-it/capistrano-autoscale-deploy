require "autoscale_deploy/version"
require "aws-sdk"

module Capistrano
  module AutoScaleDeploy
     
    set :instances, {}

    def connect_ec2
      @ec2 ||= AWS::EC2.new({
                          access_key_id: fetch(:aws_access_key_id), 
                          secret_access_key: fetch(:aws_secret_access_key), 
                          region: fetch(:aws_default_region)
      })
    end

    def sanitize_roles(roles)
     # remove :db (for migrations), remove  :primary => :true (for assets precompile)
      roles.inject([]){|acc, role| 
        if !role.is_a?(Hash) 
          acc << role if role != :db
        else 
          acc << role.reject{|k,v| k == :primary}
        end
        acc
      }
    end

    def autoscale(options = {})
      begin
        connect_ec2
      rescue Exception => e
        logger.error("unable to connect to ec2: #{e}")
      end
      
      logger.info("found #{@ec2.instances.filter('tag-key', 'AutoScaleGroup').filter('tag-value', options[:AutoScaleGroup]).filter('instance-state-code', '16').count} servers for AutoScaleGroup: #{options[:AutoScaleGroup]} ")
      
      # => filter('instance-state-code', '16') only running instances
      @ec2.instances.filter('tag-key', 'AutoScaleGroup').filter('tag-value', options[:AutoScaleGroup]).filter('instance-state-code', '16').inject(instances){|acc, instance|
        acc[instance.ip_address] = options[:deploy_roles]  
        acc
      }

      instances.each {|instance, roles|
        if instances.first[0] == instance
         server instance, *roles 
         logger.info("First Server: #{instance} - #{roles}")
        else
         logger.info("Server: #{instance} - #{sanitize_roles(roles)}")
         server instance, *sanitize_roles(roles)
        end
      }
    end
  end
end

extend Capistrano::AutoScaleDeploy