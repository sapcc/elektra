#### Servers

##### Creating new servers

By default new servers you create are not accessible from outside the network they were deployed into. To create a VM with external access follow these steps:

1. Create a new VM instance, specify the network as 'CC Shared Internal'. Since you'll most likely eventually want to login via SSH, be sure to also create or import an SSH public key (if you haven't done so already) and specify the key during VM creation.
2. Once the instance is created and an IP has been assigned from the private network, associate a Floating IP to the instance. Before doing this you will need to allocate one to your project from the External network pool.
3. The instance is now accessible via the Floating IP you assigned. However, during creation (unless you specified otherwise) it was assigned to your project's Default security group. Before you can access via SSH or ping the instance you need ensure the security group has a rule allowing ingress for TCP port 22 and/or ICMP Type 8 Code 0 respectively. Corresponding egress rules are also required.
4. You should now be able to access the instance via SSH using ssh [user]@[floating ip] the user is dependent on the image operating system e.g. for Ubuntu use 'ubuntu', for Cirros use 'cirros', for RHEL use 'fedora' and for SLES use 'root'. You also need to make sure that your SSH client is using the private key corresponding to the public key you have assigned during machine creation.
