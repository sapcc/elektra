# Changelog

## [Unreleased](https://github.com/sapcc/elektra/tree/HEAD)

[Full Changelog](https://github.com/sapcc/elektra/compare/2018.3...HEAD)

**Implemented enhancements:**

- **Mark "Interface IP" field mandatory on the "Attach Floating IP" form [\#253](https://github.com/sapcc/elektra/issues/253)**   
There is no use case, which could attach a floating IP to a VM without an interface.
- **Manila: Access IP/User [\#242](https://github.com/sapcc/elektra/issues/242)**   
Please make it easier to not allow to select not working modes on share access control.
- **Manila: messages [\#240](https://github.com/sapcc/elektra/issues/240)**   
Implement messages list+show to give users more transparency about errors: https://developer.openstack.org/api-ref/shared-file-system/\#user-messages-since-api-2-37
- **Ports UI enhancements [\#235](https://github.com/sapcc/elektra/issues/235)**   
Unify ports and fixed IP UI. Add possibility to delete ports.
- **Shared Images with Glance Ocata \(or later\) [\#234](https://github.com/sapcc/elektra/issues/234)**   
The Ocata release of Glance changed the meaning of the visibility attribute as specified here:

**Fixed bugs:**

- **When looking up a network in cloud\_admin the subnet tab is empty [\#260](https://github.com/sapcc/elektra/issues/260)**   
When using the lookup tool in the cloud\_admin area to look up a network and then switching to the subnet tab no subnets are shown.
- **Subnet tab is empty when you open the network details in a new tab [\#255](https://github.com/sapcc/elektra/issues/255)**   
However it works within the pop-up modal window
- **Automation button on new instance form doesn't work correctly [\#250](https://github.com/sapcc/elektra/issues/250)**   
\* `User data` doesn't appear and the error message appears

## [2018.3](https://github.com/sapcc/elektra/tree/2018.3) (2018-03-29)

[Full Changelog](https://github.com/sapcc/elektra/compare/2018.2...2018.3)

**Implemented enhancements:**

- **Simplify and robustify instance create dialog [\#241](https://github.com/sapcc/elektra/issues/241)**   
We have recently added some advanced features to the instance create form that relate to advanced network topics \(choosing a subnet or a predefined port\). The way they are currently presented in the form suggest to the user that they are mandatory which is not the case. We don't want people to use these options if they don't know why. Hide these options behind an "advanced networking options" toggle.
- **Toolbar enhancements [\#238](https://github.com/sapcc/elektra/issues/238)**   
We have the need to add more elements into the toolbar \(mostly filters\). Toolbar styles need to be adjusted to facilitate this.

**Fixed bugs:**

- **Revoke role from group doesn't work [\#239](https://github.com/sapcc/elektra/issues/239)**   
When you try to revoke a role from a group nothing happens. After clicking "Save" the page reloads and the role is back.
- **Router can't be deleted [\#237](https://github.com/sapcc/elektra/issues/237)**   
If you try to delete a router, there is an error that subnet or port should be given
- **Server create with subnet [\#236](https://github.com/sapcc/elektra/issues/236)**   
I get the error "Please select at a network" \(please fix the grammar too\) when creating a server, if I have selected a network + subnet, but no fixed IP
- **When creating a server the default security group is always assigned [\#231](https://github.com/sapcc/elektra/issues/231)**   
The security group that is chosen on instance creation isn't assigned. Instead the server gets the default security group.

## [2018.2](https://github.com/sapcc/elektra/tree/2018.2) (2018-02-28)

[Full Changelog](https://github.com/sapcc/elektra/compare/2018.1...2018.2)

**Implemented enhancements:**

- **Compute: Nova reset state for servers [\#208](https://github.com/sapcc/elektra/issues/208)**   
Add a 'reset state' option to servers.
- **Compute: Instance lock/unlock [\#207](https://github.com/sapcc/elektra/issues/207)**   
Add option to lock/unlock an instance. Locking an instance prevents any action on it.
- **Compute: Create server with a predefined fixed IP [\#206](https://github.com/sapcc/elektra/issues/206)**   
Currently when we create a server it gets a fixed IP assigned via DHCP. Some customers would like to choose a specific fixed IP for a new server.
- **Compute: Allow edit of server metadata \(minimum name\) [\#205](https://github.com/sapcc/elektra/issues/205)**   
Add an option to edit a server's metadata \(at least name should be editable\). Editing should only be allowed for compute\_admins.

**Fixed bugs:**

- **Volumes: Reset status policy is wrong [\#228](https://github.com/sapcc/elektra/issues/228)**   
Reset status on a volume requires "admin" role, even if the user has cinder\_admin. This is an indication that the policy doesn't have a rule for this action and falls back to the default policy.
- **LBaaS: Various UI's do not allow to delete LBaaS Object attributes [\#225](https://github.com/sapcc/elektra/issues/225)**   
Depended on the object, attributes like name, description, .. can't be set to 'blank'.
- **Manila: Error Handling [\#221](https://github.com/sapcc/elektra/issues/221)**   
When I'm out of Quota in Manila Shared File System Storage I expect a proper error to be shown.
- **SSO not working for customers [\#218](https://github.com/sapcc/elektra/issues/218)**   
According to some customers SSO for them is not working, neither on windows nor on mac. After they choose a certificate they still have to enter their user/pw.
- **Flavor: change a flavor, error, afterwards it is deleted [\#217](https://github.com/sapcc/elektra/issues/217)**   
If I edit a flavor via dashboard in ccadmin/cloud\_admin for example I activate it, I get an error and afterwards the flavor is deleted.

## [2018.1](https://github.com/sapcc/elektra/tree/2018.1) (2018-01-31)

[Full Changelog](https://github.com/sapcc/elektra/compare/2018.0...2018.1)

**Implemented enhancements:**

- **Better handling if object not found [\#212](https://github.com/sapcc/elektra/issues/212)**   
We regularly get exceptions that happen because an object we don't expect to be nil is nil \(likely because the backend call to retrieve the object is too slow\). In these cases the user should get a nice message rather than an exception.
- **Allocate Floating IP with specific address [\#211](https://github.com/sapcc/elektra/issues/211)**   
According to the network API it is possible to allocate floating ips with a specific address \(https://developer.openstack.org/api-ref/network/v2/\#create-floating-ip\). This is not yet supported by the dashboard, but is desired by customers.
- **Remove all dependencies to Fog and Misty [\#198](https://github.com/sapcc/elektra/issues/198)**   
Since Elektra has been switched to the new Elektron API client all dependencies to the previously used Fog and Misty clients should be removed.
- **Improve readiness and liveness check [\#197](https://github.com/sapcc/elektra/issues/197)**   
The liveness check starts to fail after a pod has lived for about a week.
- **Create changelog for Elektra [\#196](https://github.com/sapcc/elektra/issues/196)**   
Implement an autogeneratable changelog that is easier readable and more condensed than the commit history for others to track what we have been working on.
- **Project lookup by friendly ID  [\#195](https://github.com/sapcc/elektra/issues/195)**   
Often times we only have a project's elektra URL which contains a friendly id slug that often doesn't match the actual name if people use URL unfriendly characters in their project names.
- **Add health routes to the prometheus metric exporter [\#189](https://github.com/sapcc/elektra/issues/189)**   
With rails5 upgrade it is not necessary to have the healthcheck middleware anymore. Rewrite those checks and add them to the prometheus exporter to be used in new grafana dashboards
- **Kubernikus: ability to choose ssh key on create and edit [\#183](https://github.com/sapcc/elektra/pull/183)**   
Adds a new dropdown on the create and edit screens that allows the user to choose one of their existing keypairs or alternatively paste another public key for provisioning onto their nodes.

**Fixed bugs:**

- **Resource Management: Template error in cloud admin view [\#200](https://github.com/sapcc/elektra/issues/200)**   
User get error when trying to edit the capacity in cloud\_admin view
- **Can not attach FloatingIP on a port with multiple fixed IPs [\#199](https://github.com/sapcc/elektra/issues/199)**   
Api Bad floatingip request: Port 8a90e270-1a5b-431d-b251-f221a6e5d57c has multiple fixed IPv4 addresses. Must provide a specific IPv4 address when assigning a floating IP. and Api .
- **Friendly IDs don't work if the project name contains non-encoded HTML entities [\#188](https://github.com/sapcc/elektra/issues/188)**   
If a project name contains non-encoded HTML entities \(e.g. &\) friendly IDs don't work and the user gets an "Unauthorized" message.
- **When renaming a project the friendly ID isn't updated and user can't access project via friendly ID anymore [\#186](https://github.com/sapcc/elektra/issues/186)**   
When a project is renamed the friendly ID slug isn't updated and the user gets an Unauthorized error message when they try to access the project via the old slug.
- **server port with multiple fixed IPs [\#161](https://github.com/sapcc/elektra/issues/161)**   
usecase with multiple fixed IPs at the same port on a server and thus the same mac address is not displayed + handled correctly. UI shows only one IP out of many



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*