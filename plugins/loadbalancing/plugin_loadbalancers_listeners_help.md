#### Load Balancer as a Service (LBaaS)

##### Listeners

Load balancers can listen for requests on multiple ports. Each port has to be specified by a listener. The listener uses a pool to pass traffic from the client (i.e. a browser)
to your backend servers. Depending on the listener protocol, the load balancer intercepts and modifies the traffic. 
A Listener has the following attributes:

1. Port: The port on which the load balancer should listen
2. Protocol: The type of protocol supported by the listener / load balancer port
    * TCP: The load balancer doesn't intercept the traffic. A TCP listener can only be bound to a pool which also uses TCP as protocol. You can't use session stickiness on that level.
    * HTTP: The load balancer terminates and intercepts traffic and sets HTTP header information like X-FORWARDED-FOR. An assigned pool has to have HTTP as protocol too.
    * HTTPS: Traffic is send encrypted to the pool members. HTTPS termination has to be done on the backend servers. The backend server pool has to use HTTPS as protocol.
    * TERMINATED_HTTPS:  The load balancer terminates and intercepts traffic and sets HTTP header information like X-FORWARDED-FOR. You have to specify a certificate container which contains the needed server certificate and private key needed for the SSL decryption/termination. A corresponding pool has to have HTTP as protocol.
3. Certificate Container: Needed in case that HTTPS traffic should be terminated on load balancer. The Container has to be defined prior in the Key Manager service as Certificate Container.
4. SNI Containers: Has to be specified when Server Name Indication is used (i.e. a backend server serves different applications). The Containers have to be Key Manager Certificate Containers.