#### Load Balancer as a Service (LBaaS)

##### Load balancers

The load balancer occupies an octavia network port and has an IP address assigned from a subnet. The subnet 
has to be selected during the creation process. Afterwards it's not changeable anymore. The choosen subnet is typically an internal one which IP's are not routed to the outside. 
If you want your load balancer to be accessible from other networks like internet or other subnets, you have to attach a floating IP to it. 