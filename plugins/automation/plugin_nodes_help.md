#### Automation

##### Floating IP reported by the Arc node

By default, Arc nodes report both the fixed IP and floating IP as facts from the instance they are running on. If the floating IP is not displayed, consider the following possibilities:

1. No floating IP is assigned to the instance. In this case, navigate to the **Servers section** and allocate a floating IP to your instance.

2. The Arc node is outdated. Verify that the Arc node is still operational and running the latest version. Consult the documentation for further guidance.

3. The Arc node is not operating on an OpenStack instance. In this scenario, the floating IP cannot be retrieved because the metadata service is inaccessible from the instance.
