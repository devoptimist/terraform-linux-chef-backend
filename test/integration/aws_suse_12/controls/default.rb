frontend_details = input('frontend_details')
node_name = input('node_name')
expected_node_name = input('expected_node_name')
validation_client_name = input('validation_client_name')
expected_validation_client_name = input('expected_validation_client_name')

validation_pem = input('validation_pem')

chef_frontend_base_url = input('chef_frontend_base_url')
chef_server_org_url = input('chef_server_org_url')

client_pem = input('client_pem')

backend_servers_private_ip = input('backend_servers_private_ip')

chef_servers_private_ip = input('chef_servers_private_ip')

expected_frontend_base_url = "https://#{chef_servers_private_ip[0]}"
expected_chef_server_org_url = "https://#{chef_servers_private_ip[0]}/organizations/#{expected_validation_client_name}"

describe chef_server_org_url do
  it { should eq expected_chef_server_org_url }
end

describe chef_frontend_base_url do
  it { should eq expected_frontend_base_url }
end

describe node_name do
  it { should eq expected_node_name }
end

describe validation_client_name do
  it { should eq "#{expected_validation_client_name}-validator" }
end

describe validation_pem do
  it { should_not eq '' }
end

describe client_pem do
  it { should_not eq '' }
end

frontend_details.each do |_, v|
  backend_servers_private_ip.each do |ip|
    describe v, :sensitive do
      it { should match /#{ip}/ }
    end
  end
end

