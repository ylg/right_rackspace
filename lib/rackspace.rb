#
# Copyright (c) 2007-2009 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
module Rightscale
  module Rackspace
    class Interface

      # The login is executed automatically when one calls any othe API call.
      # The only use case  for this method is when one need to pass any custom
      # headers or vars during a login process.
      #
      #  rackspace.login #=> true
      #
      def login(opts={})
        authenticate(nil, opts)
      end

      # List all API versions supported by a Service Endpoint.
      #
      #  rackspace.list_api_versions #=> {"versions"=>[{"id"=>"v1.0", "status"=>"BETA"}]}
      #
      #  RightRackspace caching: yes, key: '/'
      #
      def list_api_versions(opts={})
        api_or_cache(:get, "/",  opts.merge(:no_service_path => true))
      end

      # Determine rate limits.
      # 
      #  rackspace.list_limits #=> 
      #    {"limits"=>
      #      {"absolute"=>
      #        {"maxNumServers"=>25, "maxIPGroups"=>50, "maxIPGroupMembers"=>25},
      #       "rate"=>
      #        [{"regex"=>".*",
      #          "verb"=>"PUT",
      #          "URI"=>"*",
      #          "remaining"=>10,
      #          "unit"=>"MINUTE",
      #          "value"=>10,
      #          "resetTime"=>1246604596},
      #         {"regex"=>"^/servers",
      #          "verb"=>"POST",
      #          "URI"=>"/servers*",
      #          "remaining"=>1000,
      #          "unit"=>"DAY",
      #          "value"=>1000,
      #          "resetTime"=>1246604596}, ...]}}
      #
      # RightRackspace caching: yes, key: '/limits'
      #
      def list_limits(opts={})
        api_or_cache(:get, "/limits",  opts)
      end

      #--------------------------------
      # Images
      #--------------------------------

      # List images.
      #
      #  # Get images list.
      #  rackspace.list_images #=>
      #    {"images"=>
      #      [{"name"=>"CentOS 5.2", "id"=>2},
      #       {"name"=>"Gentoo 2008.0", "id"=>3},
      #       {"name"=>"Debian 5.0 (lenny)", "id"=>4},
      #        ...}]}
      #
      #  # Get the detailed images description.
      #  rackspace.list_images(:detail => true) #=>
      #    {"images"=>
      #      [{"name"=>"CentOS 5.2", "id"=>2, "status"=>"ACTIVE"},
      #       {"name"=>"Gentoo 2008.0", "id"=>3, "status"=>"ACTIVE"},
      #       {"name"=>"Debian 5.0 (lenny)", "id"=>4, "status"=>"ACTIVE"},
      #       ...}]}
      #
      #  # Get the most recent changes or Rightscale::Rackspace::NoChange.
      #  # (no RightRackspace gem caching)
      #  rackspace.list_images(:detail => true, :vars => {'changes-since' => Time.now-3600}) #=>
      #    {"images"=>
      #      [{"name"=>"CentOS 5.2", "id"=>2, "status"=>"ACTIVE"},
      #       {"name"=>"Gentoo 2008.0", "id"=>3, "status"=>"ACTIVE"},
      #       {"name"=>"Debian 5.0 (lenny)", "id"=>4, "status"=>"ACTIVE"},
      #       ...}]}
      #
      # RightRackspace caching: yes, keys: '/images', '/images/detail'
      #
      def list_images(opts={})
        api_or_cache(:get, detailed_path("/images", opts), opts.merge(:incrementally => true))
      end

      # Incrementally list images.
      #
      #  # list images by 3
      #  rackspace.incrementally_list_images(0, 3, :detail=>true) do |response|
      #    puts response.inspect
      #    true
      #  end
      #
      def incrementally_list_images(offset=nil, limit=nil, opts={}, &block)
        incrementally_list_resources(:get, detailed_path("/images", opts), offset, limit, opts, &block)
      end

      # Get image data.
      #
      #  rackspace.get_image(5) #=>
      #    {"image"=>{"name"=>"Fedora 10 (Cambridge)", "id"=>5, "status"=>"ACTIVE"}}
      #
      def get_image(image_id, opts={})
        api(:get, "/images/#{image_id}", opts)
      end

      # NOT TESTED
      def create_image(server_id, name, opts={})
        body = { 'image' => { 'name' => name } }
        api(:post, "/servers/#{server_id}/actions/create_image",  opts.merge(:body => body.to_json))
      end

      #--------------------------------
      # Flavors
      #--------------------------------

      # List flavors.
      #
      #  # Get list of flavors.
      #  rackspace.list_flavors #=>
      #    {"flavors"=>
      #      [{"name"=>"256 slice", "id"=>1},
      #       {"name"=>"512 slice", "id"=>2},
      #       {"name"=>"1GB slice", "id"=>3},
      #       ...}]}
      #
      #  # Get the detailed flavors description.
      #  rackspace.list_flavors(:detail => true) #=>
      #    {"flavors"=>
      #      [{"name"=>"256 slice", "id"=>1, "ram"=>256, "disk"=>10},
      #       {"name"=>"512 slice", "id"=>2, "ram"=>512, "disk"=>20},
      #       {"name"=>"1GB slice", "id"=>3, "ram"=>1024, "disk"=>40},
      #       ...}]}
      #
      #  # Get the most recent changes or Rightscale::Rackspace::NoChange.
      #  # (no RightRackspace gem caching)
      #  rackspace.list_flavors(:detail => true, :vars => {'changes-since'=>Time.now-3600}) #=>
      #
      # RightRackspace caching: yes, keys: '/flavors', '/flavors/detail'
      #
      def list_flavors(opts={})
        api_or_cache(:get, detailed_path("/flavors", opts), opts.merge(:incrementally => true))
      end

      # Incrementally list flavors.
      #
      #  rackspace.incrementally_list_flavors(0,3) do |response|
      #    puts response.inspect
      #    true
      #  end
      #
      def incrementally_list_flavors(offset=nil, limit=nil, opts={}, &block)
        incrementally_list_resources(:get, detailed_path("/flavors", opts), offset, limit, opts, &block)
      end

      # Get flavor data.
      #
      #  rackspace.get_flavor(5) #=>
      #    {"flavor"=>{"name"=>"4GB slice", "id"=>5, "ram"=>4096, "disk"=>160}}
      #
      def get_flavor(flavor_id, opts={})
        api(:get, "/flavors/#{flavor_id}", opts)
      end

      #--------------------------------
      # Servers
      #--------------------------------

      # List servers.
      def list_servers(opts={})
        api_or_cache(:get, detailed_path("/servers", opts), opts.merge(:incrementally => true))
      end

      # NOT TESTED
      def incrementally_list_servers(offset=nil, limit=nil, opts={}, &block)
        incrementally_list_resources(:get, detailed_path("/servers", opts), offset, limit, opts, &block)
      end

      # Launch a new server.
      #  +Server_data+ is a hash of params params:
      #   Mandatory: :name, :image_id, :flavor_id
      #   Optional:  :password, :metadata, :personalities
      #
      #  rackspace.create_server(
      #    :name      => 'my-awesome-server',
      #    :image_id  => 8,
      #    :flavor_id => 4,
      #    :password  => '123456',
      #    :metadata  => { 'KD1' => 'XXXX1', 'KD2' => 'XXXX2'},
      #    :personalities => { '/home/1.txt' => 'woo-hoo',
      #                        '/home/2.rb'  => 'puts"Olalah!' }) #=>
      #    {"server"=>
      #      {"name"=>"my-awesome-server",
      #       "addresses"=>{"public"=>["174.143.56.6"], "private"=>["10.176.1.235"]},
      #       "progress"=>0,
      #       "imageId"=>8,
      #       "metadata"=>{"KD1"=>"XXXX1", "KD2"=>"XXXX2"},
      #       "adminPass"=>"my-awesome-server85lzHZ",
      #       "id"=>2290,
      #       "flavorId"=>4,
      #       "hostId"=>"19956ee1c79a57e481b652ddf818a569",
      #       "status"=>"BUILD"}}
      #
      # TODO: A password setting does not seem to be working
      #
      def create_server(server_data, opts={} )
        personality = server_data[:personalities].to_a.dup
        personality.map! { |file, contents| { 'path'=> file, 'contents' => Base64.encode64(contents).chomp } }
        body = {
          'server' => {
            'name'     => server_data[:name],
            'imageId'  => server_data[:image_id],
            'flavorId' => server_data[:flavor_id]
          }
        }
        body['server']['adminPass']   = server_data[:password] if     server_data[:password]
        body['server']['metadata']    = server_data[:metadata] unless server_data[:metadata].blank?
        body['server']['personality'] = personality            unless personality.blank?
        api(:post, "/servers", opts.merge(:body => body.to_json))
      end

      # Get a server data.
      #  rackspace.get_server(2290)
      #    {"server"=>
      #      {"name"=>"my-awesome-server",
      #       "addresses"=>{"public"=>["174.143.56.6"], "private"=>["10.176.1.235"]},
      #       "progress"=>100,
      #       "imageId"=>8,
      #       "metadata"=>{"KD1"=>"XXXX1", "KD2"=>"XXXX2"},
      #       "id"=>2290,
      #       "flavorId"=>4,
      #       "hostId"=>"19956ee1c79a57e481b652ddf818a569",
      #       "status"=>"ACTIVE"}}
      #
      def get_server(server_id, opts={})
        api(:get, "/servers/#{server_id}", opts)
      end

      # Change server name and/or password.
      # +Server_data+: :name, :password
      #
      #  rackspace.update_server(2290, :password => '12345' ) #=> true
      #  rackspace.update_server(2290, :name => 'my-super-awesome-server', :password => '67890' ) #=> true
      #
      # P.S. the changes will appers in some seconds.
      # 
      # P.P.S. changes server status: 'ACTIVE' -> 'PASSWORD'.
      #
      def update_server(server_id, server_data, opts={})
        body = { 'server' => {} }
        body['server']['name']      = server_data[:name]     if server_data[:name]
        body['server']['adminPass'] = server_data[:password] if server_data[:password]
        api(:put, "/servers/#{server_id}", opts.merge(:body => body.to_json))
      end

      # Reboot a server.
      #
      #  # Soft reboot
      #  rackspace.reboot_server(2290) #=> true
      #
      #  # Hard reboot (power off)
      #  rackspace.reboot_server(2290, :hard) #=> true
      #
      def reboot_server(server_id, type = :soft, opts={})
        body = { 'reboot' => { 'type' => type.to_s.upcase } }
        api(:post, "/servers/#{server_id}/actions/reboot", opts.merge(:body => body.to_json))
      end

      # NOT TESTED
      def rebuild_server(server_id, image_id, opts={})
        body = { 'rebuild' => { 'imageId' => image_id } }
        api(:post, "/servers/#{server_id}/actions/rebuild", opts.merge(:body => body.to_json))
      end

      # Resize a server.
      #
      #  rackspace.resize_server(2290, 3) #=> true
      #  rackspace.get_server(2290) #=>
      #    {"server"=>
      #      {"name"=>"my-awesome-server",
      #       "addresses"=>{"public"=>["174.143.56.6"], "private"=>["10.176.1.235"]},
      #       "progress"=>0,
      #       "imageId"=>8,
      #       "metadata"=>{"KD1"=>"XXXX1", "KD2"=>"XXXX2"},
      #       "id"=>2290,
      #       "flavorId"=>4,
      #       "hostId"=>"19956ee1c79a57e481b652ddf818a569",
      #       "status"=>"QUEUE_RESIZE"}}
      #
      # P.S. changes server status: 'ACTIVE' -> 'QUEUE_RESIZE' -> 'PREP_RESIZE' -> 'RESIZE' -> 'VERIFY_RESIZE'
      #
      def resize_server(server_id, flavor_id, opts={})
        body = { 'resize' => { 'flavorId' => flavor_id } }
        api(:post, "/servers/#{server_id}/actions/resize", opts.merge(:body => body.to_json))
      end

      # Confirm a server resize action.
      #
      #  rackspace.confirm_resized_server(2290) #=> true
      #
      # P.S. changes server status: 'VERIFY_RESIZE' -> 'ACTIVE'
      #
      def confirm_resized_server(server_id, opts={})
        api(:put, "/servers/#{server_id}/actions/resize", opts)
      end

      # Revert a server resize action.
      #
      #  rackspace.revert_resized_server(2290) #=> true
      #
      # P.S. changes server status: 'VERIFY_RESIZE' -> 'ACTIVE'
      #
      def revert_resized_server(server_id, opts={})
        api(:delete, "/servers/#{server_id}/actions/resize", opts)
      end

      # Share an IP from an existing server in the specified shared IP group to another
      # specified server in the same group.
      #
      #  rackspace.share_ip_address(2296, 42, "174.143.56.6") #=> true
      #  rackspace.get_server(2290) #=>
      #    {"server"=>
      #      {"name"=>"my-awesome-server",
      #       "addresses"=>
      #        {"public"=>["174.143.56.6", "174.143.56.13"], "private"=>["10.176.1.235"]},
      #       "progress"=>100,
      #       "imageId"=>8,
      #       "metadata"=>{"KD1"=>"XXXX1", "KD2"=>"XXXX2"},
      #       "id"=>2290,
      #       "flavorId"=>3,
      #       "hostId"=>"1d5fa1271f57354d9e2861e848568eb3",
      #       "status"=>"SHARE_IP_NO_CONFIG"}}
      def share_ip_address(server_id, shared_ip_group_id, address, opts={})
        body = { 
          'shareIp' => {
            'sharedIpGroupId' => shared_ip_group_id,
            'addr'            => address
          }
        }
        api(:post, "/servers/#{server_id}/actions/share_ip",  opts.merge(:body => body.to_json))
      end

      # Remove a shared IP address from the specified server
      #
      #  rackspace.unshare_ip_address(2296, "174.143.56.6") #=> true
      #
      def unshare_ip_address(server_id, address, opts={})
        body = { 'unshareIp' => { 'addr' => address } }
        api(:post, "/servers/#{server_id}/actions/unshare_ip",  opts.merge(:body => body.to_json))
      end

      # Delete a server.
      # Returns +true+ on success.
      def delete_server(server_id, opts={})
        api(:delete, "/servers/#{server_id}", opts)
      end

      #--------------------------------
      # Backup Schedules
      #--------------------------------

      # NOT TESTED
      def get_backup_schedule(server_id, opts={})
        api(:get, "/servers/#{server_id}/backup_schedule", opts)
      end

      # NOT TESTED
      def update_backup_schedule(server_id, enabled, daily=nil, weekly=nil, opts={})
        body = { 'backupSchedule' => { 'enabled' => enabled.to_s } }
        body['backupSchedule']['daily']  = daily  unless daily.blank?
        body['backupSchedule']['weekly'] = weekly unless weekly.blank?
        api(:post, "/servers/#{server_id}/backup_schedule", opts.merge(:body => body.to_json))
      end

      # NOT TESTED
      def delete_backup_schedule(server_id, opts={})
        api(:delete, "/servers/#{server_id}/backup_schedule", opts)
      end

      #--------------------------------
      # Shared IP Groups
      #--------------------------------

      # List shared IP groups.
      #
      # RightRackspace caching: yes, keys: '/shared_ip_groups', '/shared_ip_groups/detail'
      #
      def list_shared_ip_groups(opts={})
        api_or_cache(:get, detailed_path("/shared_ip_groups", opts), opts.merge(:incrementally => true))
      end

      # Incrementally list IP groups.
      #
      #  # list groups by 5
      #  rackspace.incrementally_list_shared_ip_groups(0, 5) do |x|
      #    puts x.inspect
      #    true
      #  end
      #
      def incrementally_list_shared_ip_groups(offset=nil, limit=nil, opts={}, &block)
        incrementally_list_resources(:get, detailed_path("/shared_ip_groups", opts), offset, limit, opts, &block)
      end

      # Create a new shared IP group.
      #
      #  rackspace.create_shared_ip_group('my_awesome_group', 2290) #=>
      #   {"sharedIpGroup"=>{"name"=>"my_awesome_group", "id"=>42}}
      #
      def create_shared_ip_group(name, server_id=nil, opts={})
        body = { 'sharedIpGroup' => { 'name' => name } }
        body['sharedIpGroup']['server'] = server_id unless server_id.blank?
        api(:post, "/shared_ip_groups", opts.merge(:body => body.to_json))
      end

      # Get shared IP group data.
      # 
      #   rackspace.list_shared_ip_groups #=>
      #    {"sharedIpGroups"=>[{"name"=>"my_awesome_group", "id"=>42, "servers"=>[2290]}]}
      #
      def get_shared_ip_group(shared_ip_group_id, opts={})
        api(:get, "/shared_ip_groups/#{shared_ip_group_id}", opts)
      end

      # Delete an IP group.
      #
      #   rackspace.delete_shared_ip_group(42) #=> true
      #
      def delete_shared_ip_group(shared_ip_group_id, opts={})
        api(:delete, "/shared_ip_groups/#{shared_ip_group_id}", opts)
      end

    end
  end
end