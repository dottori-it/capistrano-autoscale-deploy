require "capistrano"
require "aws-sdk-v1"

module Capistrano
  module AutoScaleDeploy
    def self.extend(configuration)
      configuration.load do
        Capistrano::Configuration.instance.load do 
          _cset(:instances, {})

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
              logger.info("unable to connect to ec2: #{e}")
            end
            
            # => filter('instance-state-code', '16') only running instances
            @ec2_instances = @ec2.instances.filter('tag-key', 'aws:autoscaling:groupName').filter('tag-value', options[:AutoScaleGroup]).filter('instance-state-code', '16')
            
            logger.info("found #{@ec2_instances.count} servers for AutoScaleGroup: #{options[:AutoScaleGroup]} ")
            
            @ec2_instances.inject(instances){|acc, instance|
              acc[instance.private_ip_address] = options[:deploy_roles]  
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
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::AutoScaleDeploy.extend(Capistrano::Configuration.instance)
end
