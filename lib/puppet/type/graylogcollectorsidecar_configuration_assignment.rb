Puppet::Type.newtype(:graylogcollectorsidecar_configuration_assignment) do
    @doc = "Add and remove sidecar configurations to node."

    ensurable
    
    newparam(:configuration) do
        desc "Configuration Name"
    end

    newparam(:api_token) do
        desc "API token to use."
    end

    newparam(:api_url) do
        desc "URL of the graylog API."
    end
end