# Puppet::Type.type(:graylogcollectorsidecar_configuration_assignment).provide(:rest) do
#     desc "Use curl to interact with graylog API"

    require 'net/https'
    require 'json'

    def create
        if registered?(resource)
            unless exists?(resource)
                nodeid = get_nodeid
                uri    = URI.parse(resource[:api_url] + '/sidecars/configurations')
                body   = {
                    
                }
            end
        end
    end

    def destroy
        if exists?
        end
    end

    def exists?(resource)
        configuration = get_configuration(resource)
        nodeid        = get_nodeid
        if configuration != false
            uri    = URI.parse(resource[:api_url] + '/sidecar/configurations/' + configuration['id']/sidecars)
            resp   = query('get', uri, '', resource)
            if resp.code == '200'
                JSON.parse(resp.body)['sidecar_ids'].each | sidecar_id |
                    if sidecar_id == nodeid
                        return true
                    end
                end
            end
        end
        return false
    end

    def registered?(resource)
        nodeid = get_nodeid
        uri    = URI.parse(resource[:api_url] + '/sidecars/' + nodeid)
        resp   = query('get', uri, '', resource)
        if resp.code == '200'
            if JSON.parse(resp.body)['active'] == true
                return true
            end
        end
        return false
    end

    def get_configuration(resource)
        uri  = URI.parse(resource[:api_url] + '/sidecar/configurations')
        resp = query('get', uri, '', resource)
        if resp.code == '200'
            JSON.parse(resp.body)['configurations'].each | configuration |
                if configuration['name'] == resource[:configuration]
                    return configuration
                end
            end
        end
        return false
    end

    def get_nodeid
        config_file = File.open('/etc/graylog/sidecar/node-id')
        nodeid = config_file.read
        config_file.close
        return nodeid
    end

    def query(verb, uri, payload, resource)
        unless uri.nil?
            http              = Net::HTTP.new(uri.host, 443)
            http.use_ssl      = true
            http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
            http.ca_file      = '/etc/ssl/certs/ebuero-ca.pem'
            if verb == 'get'
                request = Net::HTTP::Get.new uri
            elsif verb == 'post'
                request = Net::HTTP::Post.new uri
                request.body = payload.to_json
            end
            request["Accept"] = "application/json"
            request.basic_auth resource[:api_token], 'token'
            resp = http.request request
            return resp
        end
    end
# end

# for local testing
resource = {
    :api_url   => "https://vmgraylog21.coast.ebuero.de:443/api",
    :api_token => "1op854amrsjml7kongd10ggkcc4o55fq69djqkf08nnh5i4pq0lo",
    :configuration => "test-apache"
}
if registered?(resource)
