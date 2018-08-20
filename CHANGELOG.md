# Changelog

## [Unreleased](https://github.com/sapcc/elektra/tree/HEAD)

[Full Changelog](https://github.com/sapcc/elektra/compare/2018.7...HEAD)

**Implemented enhancements:**

- **\[Automation\]: error message when running an automation on an offline node [\#333](https://github.com/sapcc/elektra/issues/333)**   
A customer has reported that it's possible to execute automations on offline nodes.

**Fixed bugs:**

- **Users who are assigned to groups but do not have domain permission can not log in. [\#344](https://github.com/sapcc/elektra/issues/344)**   
Users are logged in Elektra always unscoped and then rescoped to the requested scope. But before the rescoping happens, the dashboard controller tests whether the user has permissions. This check is incorrect! It tests only if the user is assigned to a group that is also assigned to the requested domain. This is not enough, because a group role assignment can exist with roles for which rescoping is not allowed.
- **Network show: ports tab runs into hard limit \(max 500\) [\#338](https://github.com/sapcc/elektra/issues/338)**   
In big projects with lots of ports the ports tab of the network show dialog displays only 500 ports because of the hard limit set in the backend. Looks like we need to add paging here. Example in eu-de-1 go to: /s4/s4-vlab/networking/networks/private?overlay=2b8ddbb9-f316-4050-a9f1-c97cf046cc04 and then the ports tab
- **Uncaught exception after removing MONSOON3\_DOMAIN\_USERS group from project [\#204](https://github.com/sapcc/elektra/issues/204)**   
Bug report:

## [2018.7](https://github.com/sapcc/elektra/tree/2018.7) (2018-07-25)

[Full Changelog](https://github.com/sapcc/elektra/compare/2018.6...2018.7)

**Implemented enhancements:**

- **Cloudops: Make nav look like a nav [\#328](https://github.com/sapcc/elektra/issues/328)**   
The navigation in the cloudops area doesn't really look like a navigation right now. Create a nav style for it.
- **Testing: Research and POC testing frameworks for React [\#326](https://github.com/sapcc/elektra/issues/326)**   
Since the number of react apps in Elektra is ever increasing we need a way to write tests for them to automatically test in our deployment pipeline.
- **Universal Search: Add cache age info to search results [\#322](https://github.com/sapcc/elektra/issues/322)**   
Since the universal search operates on cached objects the search results can sometimes be not entirely accurate. To give the user an idea an indication that a result might be out of date display cache age for the result.
- **Display Cost Report for Domains [\#315](https://github.com/sapcc/elektra/issues/315)**   
Make the existing plugin to show the cost report for projects also available for domains.
- **Policies: Update policies for viewer roles as necessary [\#314](https://github.com/sapcc/elektra/issues/314)**   
With the introduction of viewer roles for every service we need to ensure that Elektra lets people with a viewer role use read actions as applicable. Update all plugin policies as necessary.
- **Universal Search: Add search by friendly ID [\#310](https://github.com/sapcc/elektra/issues/310)**   
Add generated friendly ID's to the object cache so that projects can be found by friendly ID.
- **Ports: Edit dialog and security group selection [\#301](https://github.com/sapcc/elektra/issues/301)**   
We can select a security group for a port when we attach a new interface to an instance, but since we don't have an edit dialog for ports it's not possible to change it later. Also the server UI doesn't show which security groups are attached to which ports.
- **Improve performance [\#329](https://github.com/sapcc/elektra/pull/329)**   
We have identified two major factors that slow down rendering time of pages in Elektra. 1\) Getting role assignments and 2\) Rendering the project tree. We need to improve this before we can roll out the new support team authorizations.
- **Add policy rules for viewer roles [\#319](https://github.com/sapcc/elektra/pull/319)**   
This adds the necessary policy entries to support viewer roles for all plugins that were missing them: identity, images, masterdata.

**Fixed bugs:**

- **Ports UI shows a JSON Outup when using browser navigation [\#331](https://github.com/sapcc/elektra/issues/331)**   
We use the same route for rendering the HTML page and the JSON Response. It is decided by the headers whether HTML or JSON is delivered. This does not work if the user uses the browser navigation. Then, because of browser cache, JSON comes, although HTML is expected.
- **Role assignment: Assigning roles to technical users results in error [\#313](https://github.com/sapcc/elektra/issues/313)**   
Trying to assign a role to a technical user results in the error message "User unknown" after clicking the "save" button.
- **react ajax calls do not work in \<= IE10 [\#312](https://github.com/sapcc/elektra/issues/312)**   
We use the window.location.origin in axios to build the baseURL for ajax calls. This attribute is not available in Internet Explorer version less than 11.

## [2018.6](https://github.com/sapcc/elektra/tree/2018.6) (2018-06-29)

[Full Changelog](https://github.com/sapcc/elektra/compare/2018.5...2018.6)

**Implemented enhancements:**

- **Billing: New plugin for displaying project costs [\#304](https://github.com/sapcc/elektra/issues/304)**   
The billing team have created a new API that delivers cost information per service \(based on consumption/quota\) for each project. It shows what the customer has paid every month and how the cost was distributed. Build a UI that renders a chart for the monthly costs and allows viewing detailed information for each month.
- **Object Cache: DB cleanup job [\#296](https://github.com/sapcc/elektra/issues/296)**   
Add an automatic job which cleans up object cache entries that haven't been updated in over a month to prevent object sprawl in cache table.
- **Cloudops: Universal Search improvements [\#295](https://github.com/sapcc/elektra/issues/295)**   
Elektra link to project from search results. Add more search fields: floating IP, mac address, cidr, descriptions,...\). Search for Manila log messages.
- **Cloudops: Project user role assignment UI [\#294](https://github.com/sapcc/elektra/issues/294)**   
Add project user role assignment UI to Cloudops. This shall be accessible from a project view in the universal search results and also standalone. New features: "select admin roles", "remove all roles"
- **Cloudops: Live Search [\#302](https://github.com/sapcc/elektra/pull/302)**   
If the search term can't be found in the Object Cache, allow the user to perform a live search against the OpenStack backend \(user needs to specify object type so we know which API to search against\).

**Fixed bugs:**

- **Compute: Instance create also creates unnecessary ports [\#308](https://github.com/sapcc/elektra/issues/308)**   
In the instance create dialog when the user selects a network a subnet is also selected because the select box doesn't have a blank option. This causes a port to be created with the subnet and flag "preserve on delete" in the Neutron database.
- **Project wizard can't be completed in projects with non-standard external networks [\#299](https://github.com/sapcc/elektra/issues/299)**   
We have some customer-specific domains where the external network names don't follow our naming convention. In these cases the project wizard can never be completed because the wizard checks whether the project has an rbac for one of the standard networks \(which don't exist in these domains\). If a project has a non-standard external network designed the wizard should checkmark the network box as completed.

## [2018.5](https://github.com/sapcc/elektra/tree/2018.5) (2018-05-31)

[Full Changelog](https://github.com/sapcc/elektra/compare/2018.4...2018.5)

**Implemented enhancements:**

- **Compute: Mark baremetal servers in the server list and server show screens [\#269](https://github.com/sapcc/elektra/issues/269)**   
It would be convenient to be able to see at a glance which servers are baremetal nodes and which are VMs.
- **Manila: extend/shrink share [\#202](https://github.com/sapcc/elektra/issues/202)**   
Add the ability to extend or shrink a manila share
- **Cloudops layout [\#281](https://github.com/sapcc/elektra/pull/281)**   
Layout for new cloudops area. This has a new type of "always there" navigation with integrated universal search bar which will eventually be responsive and attach to the left side on very wide screens.

**Fixed bugs:**

- **In some cases not all private networks are shown in networks list [\#293](https://github.com/sapcc/elektra/issues/293)**   
This is due to a bug in Neutron where it can happen that not all networks of a project are returned if the api is called using the "limit" parameter.
- **Keymanager: Error when trying to display wildcard certs [\#289](https://github.com/sapcc/elektra/issues/289)**   
The Keymanager UI throws an error when you try to show a wildcard cert.
- **Unable to create VM from the private image via Dashboard [\#277](https://github.com/sapcc/elektra/issues/277)**   
The way images are categorized has changed in newer versions of the Glance service. In regions where Glance has been upgraded to Ocata you will see the new UI with the new categories. The snapshots, for example, get the status shared and not private as before.

## [2018.4](https://github.com/sapcc/elektra/tree/2018.4) (2018-04-30)

[Full Changelog](https://github.com/sapcc/elektra/compare/2018.3...2018.4)

**Implemented enhancements:**

- **Volume Index: Timeout for projects with large number of servers [\#271](https://github.com/sapcc/elektra/issues/271)**   
When going to the volumes index page in projects with a very large number of servers you get a timeout.
- **Object Cache [\#266](https://github.com/sapcc/elektra/issues/266)**   
Cache all objects coming from the API. Elektron with its middlewares seems to be the most suitable place for it.
- **User request: Use monospace font for user data textarea in create server dialog [\#261](https://github.com/sapcc/elektra/issues/261)**   
Text area currently uses our regular non-monopaced font which makes it harder to format the cloud config file.
- **Mark "Interface IP" field mandatory on the "Attach Floating IP" form [\#253](https://github.com/sapcc/elektra/issues/253)**   
There is no use case which could attach a floating IP to a VM without an interface.
- **Manila: Access IP/User [\#242](https://github.com/sapcc/elektra/issues/242)**   
Please make it easier to not allow to select not working modes on share access control.
- **Manila: messages [\#240](https://github.com/sapcc/elektra/issues/240)**   
Implement messages list+show to give users more transparency about errors: https://developer.openstack.org/api-ref/shared-file-system/\#user-messages-since-api-2-37
- **Ports UI enhancements [\#235](https://github.com/sapcc/elektra/issues/235)**   
Unify ports and fixed IP UI. Add possibility to delete ports.
- **Shared Images with Glance Ocata \(or later\) [\#234](https://github.com/sapcc/elektra/issues/234)**   
The Ocata release of Glance changed the meaning of the visibility attribute as specified here: https://wiki.openstack.org/wiki/Glance-v2-community-image-visibility-design
- **Admin Service: Find projects by floating IP or DNS record [\#201](https://github.com/sapcc/elektra/issues/201)**   
Implement a service for admins that allows an input of floating IP or DNS record. The service should then find which project the input belongs to and display the following information about the project:
- **Cloudops search, object cache [\#268](https://github.com/sapcc/elektra/pull/268)**   
Use the object read cache to create a universal search that allows search for any object by id or name without having to specify what type of object it is and where it is located

**Fixed bugs:**

- **When looking up a network in cloud\_admin the subnet tab is empty [\#260](https://github.com/sapcc/elektra/issues/260)**   
When using the lookup tool in the cloud\_admin area to look up a network and then switching to the subnet tab no subnets are shown.
- **Subnet tab is empty when you open the network details in a new tab [\#255](https://github.com/sapcc/elektra/issues/255)**   
However it works within the pop-up modal window
- **Automation button on new instance form doesn't work correctly [\#250](https://github.com/sapcc/elektra/issues/250)**   
\* `User data` doesn't appear instead an error message is shown

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
