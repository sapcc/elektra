#### Automation

##### Floating IP reported by the Arc node

By default Arc nodes report the fixed IP and floating IP as a fact from the instance they run on. If the floating IP is not shown check the following:

* There is no floating IP assigned to the instance. If this is the case go the **servers area** and assign a floating IP to your instance.
* The Arc node is outdated. Check if the Arc node is still running and if it is running with the latest version. Check the documentation for more help.
* The Arc node is not running on an Openstack instance. In this case cannot be retrieved because the metadata service is not reachable from the instance.
