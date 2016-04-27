### General Advice
This platform will support the **lbaas v2 api**. Therefore only **neutron lbaas v2 commands** must be used.

### Quick Help
[OpenStack neutron command line tool](http://docs.openstack.org/developer/python-neutronclient)

`neutron help | grep lbaas`
Filters the neutron cli help for relevant lbaas v2 commands

`neutron help <command>`
Show help for command

### Example for creating a Load Balancer with v2

0. Determine a tenant subnet where load balancer should be deployed in.  
`neutron subnet-list`
1. Create a new load balancer using the lbaas-loadbalancer-create command with a name and a subnet name.  
**Note:** The creation of the Load Balancer requires a tenant network and not an external network.  
`neutron lbaas-loadbalancer-create --name <lb-name> <subnet>`
2. Create a new listener for the load balancer using the lbaas-listener-create. Give listener the name of the load balancer, the protocol, the protocol port and a name for the listener.  
`neutron lbaas-listener-create --loadbalancer <lb-name> --protocol HTTP --protocol-port=<port> --name <listener-name>`
3. Create a new pool for the load balancer using the lbaas-pool-create command. Creating a new pool requires the load balancing algorithm, the name of the listener, the protocol and a name for the pool.  
`neutron lbaas-pool-create --lb-algorithm ROUND_ROBIN --listener <listener-name> --protocol HTTP --name <pool-name>`
4. Add members to the load balancer pool by running the lbaas-member-create command. The command requires the subnet, IP address, protocol port and the name of the pool for each virtual machine you'd like to include into the load balancer pool.  
`neutron lbaas-member-create --subnet <subnet> --address <ip address vm1> --protocol-port <port> <pool-name>`
`neutron lbaas-member-create --subnet <subnet> --address <ip address vm2> --protocol-port <port> <pool-name>`
5. Create a healthcheck by running lbaas-healthmonitor-create command and assign it to the pool. Set the type, a url-path, delay, timeout and max-retries and the pool name  
`neutron lbaas-healthmonitor-create --delay 5 --type HTTP --url-path </healthcheck-path> --max-retries 3 --timeout 2 --pool <pool-name>`
6. Display the current state of the load balancer and values with lbaas-loadbalancer-show.  
`neutron lbaas-loadbalancer-show <lb-name>`
7. You need to assign the floating IP to lbaas VIP so it could be accessed from external network.  
`fixedip_vip=$(neutron lbaas-loadbalancer-list | awk '/<lb-name>/ {print $6}')`
`portuuid_vip=$(neutron port-list | grep $fixedip_vip | awk '{print $2}')`
8. Create and associate floating IP address to lbaas VIP address.  
`neutron floatingip-create ext-net --port-id $portuuid_vip`

### Most Used Commands
`neutron lbaas-loadbalancer-list`

`neutron lbaas-loadbalancer-show <lb-name>`

`neutron lbaas-member-create`
