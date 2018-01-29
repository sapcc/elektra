# Changelog

## [Unreleased](https://github.com/sapcc/elektra/tree/HEAD)

[Full Changelog](https://github.com/sapcc/elektra/compare/2018.0...HEAD)

**Implemented enhancements:**

- Remove all dependencies to Fog and Misty [\#198](https://github.com/sapcc/elektra/issues/198)   
Since Elektra has been switched to the new Elektron API client all dependencies to the previously used Fog and Misty clients should be removed.
- Improve readiness and liveness check [\#197](https://github.com/sapcc/elektra/issues/197)   
Some weeks ago we noticed that after having run for a longer time suddenly the liveness checks start to fail quite often.
- Create changelog for Elektra [\#196](https://github.com/sapcc/elektra/issues/196)   
We need something that is easier readable and more condensed than the commit history for others to track what we have been working on.
- Project lookup by friendly ID  [\#195](https://github.com/sapcc/elektra/issues/195)   
Often times we only have a project's elektra URL which contains a friendly id slug that often doesn't match the actual name if people use URL unfriendly characters in their project names.

**Fixed bugs:**

- ActionView::Template::Error in plugins/resource\_management [\#200](https://github.com/sapcc/elektra/issues/200)   
NoMethodError
- Can not attach FloatingIP on a port with multiple fixed IPs [\#199](https://github.com/sapcc/elektra/issues/199)   
Api Bad floatingip request: Port 8a90e270-1a5b-431d-b251-f221a6e5d57c has multiple fixed IPv4 addresses. Must provide a specific IPv4 address when assigning a floating IP. and Api .
- Friendly IDs don't work if the project name contains non-encoded HTML entities [\#188](https://github.com/sapcc/elektra/issues/188)   
If a project name contains non-encoded HTML entities \(e.g. &\) friendly IDs don't work and the user gets an "Unauthorized" message.
- When renaming a project the friendly ID isn't updated and user can't access project via friendly ID anymore [\#186](https://github.com/sapcc/elektra/issues/186)   
When a project is renamed the friendly ID slug isn't updated and the user gets an Unauthorized error message when they try to access the project via the old slug.

**Closed issues:**

- Add health routes to the prometheus metric exporter [\#189](https://github.com/sapcc/elektra/issues/189)   
With rails5 upgrade is not anymore necessary to have the middleware healthcheck. Liveliness and Readiness check can be written from same controller having in the readiness action a Modell call to check if the database is still up and running.
- server port with multiple fixed IPs [\#161](https://github.com/sapcc/elektra/issues/161)   
usecase with multiple fixed IPs at the same port on a server and thus the same mac address is not displayed + handled correctly. UI shows only one IP out of many
- After sign in demo user, bad URI\(is not URI?\) [\#154](https://github.com/sapcc/elektra/issues/154)   
I access ` localhost:3000/Default`

**Merged pull requests:**

- Remove misty and fog [\#194](https://github.com/sapcc/elektra/pull/194) ([andypf](https://github.com/andypf))   
Remove all obsolete dependencies:
- Lb on elektron [\#193](https://github.com/sapcc/elektra/pull/193) ([andypf](https://github.com/andypf))   
Switch loadbalancing to elektron \(the new api client for elektra\)
- Health checks [\#191](https://github.com/sapcc/elektra/pull/191) ([ArtieReus](https://github.com/ArtieReus))
- Adds Automatic Changelog Generation [\#190](https://github.com/sapcc/elektra/pull/190) ([ArtieReus](https://github.com/ArtieReus))   
This commits adds a Docker image that includes a tool that automatically generates changelogs.
- Swift on elektron [\#187](https://github.com/sapcc/elektra/pull/187) ([andypf](https://github.com/andypf))
- Networking on elektron [\#185](https://github.com/sapcc/elektra/pull/185) ([andypf](https://github.com/andypf))
- Compute on elektron [\#184](https://github.com/sapcc/elektra/pull/184) ([andypf](https://github.com/andypf))
- Kubernikus: ability to choose ssh key on create and edit [\#183](https://github.com/sapcc/elektra/pull/183) ([edda](https://github.com/edda))   
Adds a new dropdown on the create and edit screens that allows the user to choose one of their existing keypairs or alternatively paste another public key for provisioning onto their nodes.
- DHCP agent mgmt [\#182](https://github.com/sapcc/elektra/pull/182) ([Carthaca](https://github.com/Carthaca))   
stolen from network access the js could be more functional instead of the whole reloading 🙄
- finish moving identity to elektron [\#181](https://github.com/sapcc/elektra/pull/181) ([andypf](https://github.com/andypf))
- Sec group enforce [\#180](https://github.com/sapcc/elektra/pull/180) ([Carthaca](https://github.com/Carthaca))   
@andypf can you have a look please?
- Core on elektron [\#179](https://github.com/sapcc/elektra/pull/179) ([andypf](https://github.com/andypf))
- Remove mistycc [\#178](https://github.com/sapcc/elektra/pull/178) ([andypf](https://github.com/andypf))
- Kubernikus metadata and advanced options [\#175](https://github.com/sapcc/elektra/pull/175) ([edda](https://github.com/edda))   
Add advanced options form to create and edit dialog. Pull flavors from metadata api.
- Dns on elektron [\#174](https://github.com/sapcc/elektra/pull/174) ([andypf](https://github.com/andypf))

## [2018.0](https://github.com/sapcc/elektra/tree/2018.0) (2018-01-05)

[Full Changelog](https://github.com/sapcc/elektra/compare/d3940825b6f9ef33cf8697949c4e235c1da7445e...2018.0)

**Fixed bugs:**

- project request workflow is broken when cost control service is used [\#34](https://github.com/sapcc/elektra/issues/34)   
Consider a situation where the `sapcc-billing` backend service is available. A user logs on and wants to request a new project. This action happens in the domain scope, where Keystone does not deliver a service catalog. Therefore, \[`services.cost\_control.available?`\]\(https://github.com/sapcc/elektra/blob/ce4d596e6f1f029d06e55b87d97cad1a397c3cb2/plugins/cost\_control/app/services/service\_layer/cost\_control\_service.rb\#L15\) is false and the project request form \(and thus, the project request\) will \[not contain the form fields\]\(https://github.com/sapcc/elektra/blob/ce4d596e6f1f029d06e55b87d97cad1a397c3cb2/plugins/identity/app/views/identity/projects/shared/\_form.html.haml\#L23\) for specifying a cost object.
- Masterdata ui fix [\#153](https://github.com/sapcc/elektra/pull/153) ([hgw77](https://github.com/hgw77))   
this covers some user feedback

**Closed issues:**

- hi dude developerS [\#157](https://github.com/sapcc/elektra/issues/157)   
i was looking elektra travis,
- \[Monsoon Openstack Auth\] login\_form\_user -\> failed. The resource could not be found. [\#151](https://github.com/sapcc/elektra/issues/151)   
When I configure the .env file, foreman start run the project, visit localhost: 3000/Default, enter the login page, enter the horizon existing account, prompt
- Target audience not apparent from project page [\#128](https://github.com/sapcc/elektra/issues/128)   
What is not apparent from the project page is wether Elektra is geared towards public or private clouds.
- Project domain name is hard-coded [\#126](https://github.com/sapcc/elektra/issues/126)   
Currently the project's domain-name `cloud.sap` is hard-coded in the project, for example:
- Unsupported Domain notification [\#125](https://github.com/sapcc/elektra/issues/125)   
I’m trying to figure out how to implement Elektra with OpenStack Ansible instead of DevStack. I keep getting an Unsupported Domain notification in the view.
- Service User Authentication Error [\#47](https://github.com/sapcc/elektra/issues/47)   
Elecktra is not able to authenticate service user. I have update the .env file
- Unsupported Domain [\#4](https://github.com/sapcc/elektra/issues/4)   
Using a DevStack installation at `commit e08f45f77f73392b2524992d8ca6c4e628400bcc` in \* branch `stable/mitaka`

**Merged pull requests:**

- Baremetal on elektron [\#173](https://github.com/sapcc/elektra/pull/173) ([andypf](https://github.com/andypf))
- Volumes on elektron [\#172](https://github.com/sapcc/elektra/pull/172) ([andypf](https://github.com/andypf))
- Images on elektron [\#171](https://github.com/sapcc/elektra/pull/171) ([andypf](https://github.com/andypf))
- Share types [\#170](https://github.com/sapcc/elektra/pull/170) ([andypf](https://github.com/andypf))
- some small bugfixes related to misty migration [\#169](https://github.com/sapcc/elektra/pull/169) ([hgw77](https://github.com/hgw77))
- bugfix for content-type and folder [\#168](https://github.com/sapcc/elektra/pull/168) ([hgw77](https://github.com/hgw77))
- add UI for ports [\#167](https://github.com/sapcc/elektra/pull/167) ([andypf](https://github.com/andypf))
- Server floating ips [\#166](https://github.com/sapcc/elektra/pull/166) ([andypf](https://github.com/andypf))
- Object storage to misty [\#165](https://github.com/sapcc/elektra/pull/165) ([hgw77](https://github.com/hgw77))
- Update of snapshot note on UI. [\#164](https://github.com/sapcc/elektra/pull/164) ([bozinsky](https://github.com/bozinsky))
- \[compute\] list instance actions in policy and allow for member [\#163](https://github.com/sapcc/elektra/pull/163) ([Carthaca](https://github.com/Carthaca))   
Hi @andypf, can you please have a look?
- Es6 ie11 new [\#162](https://github.com/sapcc/elektra/pull/162) ([andypf](https://github.com/andypf))
- Rails5.1 react [\#158](https://github.com/sapcc/elektra/pull/158) ([andypf](https://github.com/andypf))
- Rails5.1 react [\#156](https://github.com/sapcc/elektra/pull/156) ([andypf](https://github.com/andypf))
- fix create masterdata bug with loooong description [\#155](https://github.com/sapcc/elektra/pull/155) ([hgw77](https://github.com/hgw77))
- adapt to latest Hermes API [\#152](https://github.com/sapcc/elektra/pull/152) ([jobrs](https://github.com/jobrs))   
I can't claim to have understood the coffee syntax, but I am optimistic that this change might even work ;-\) please have a look.
- Backup networks [\#150](https://github.com/sapcc/elektra/pull/150) ([andypf](https://github.com/andypf))
- The CAM url should be configurable, since staging has a different one [\#149](https://github.com/sapcc/elektra/pull/149) ([ruvr](https://github.com/ruvr))   
Something along these lines?
- Maia/Metrics [\#148](https://github.com/sapcc/elektra/pull/148) ([hgw77](https://github.com/hgw77))   
!\[screenshot-2017-10-11 ccloud monsoon3 staging 2\]\(https://user-images.githubusercontent.com/5598283/31448697-67044a08-aea5-11e7-8f66-2e372cb6f85e.png\)
- Inquiry metrics [\#147](https://github.com/sapcc/elektra/pull/147) ([andypf](https://github.com/andypf))
- less confusing caption [\#146](https://github.com/sapcc/elektra/pull/146) ([majewsky](https://github.com/majewsky))   
Users are confused by this, see Slack this morning.
- prevent change of classname from plural to singular [\#145](https://github.com/sapcc/elektra/pull/145) ([hgw77](https://github.com/hgw77))   
with that changes I can create a maia or masterdata plugin without problems :-\)
- Remove cost control [\#144](https://github.com/sapcc/elektra/pull/144) ([hgw77](https://github.com/hgw77))
- \(snapshots\) refine notification. just windows not working. [\#143](https://github.com/sapcc/elektra/pull/143) ([bozinsky](https://github.com/bozinsky))   
@edda we have all linux vms snapshots working, hence refinement of the alert info.
- Masterdata improvements [\#142](https://github.com/sapcc/elektra/pull/142) ([hgw77](https://github.com/hgw77))
- small bugfixes [\#141](https://github.com/sapcc/elektra/pull/141) ([hgw77](https://github.com/hgw77))
- Dns refactoring [\#140](https://github.com/sapcc/elektra/pull/140) ([andypf](https://github.com/andypf))
- wizard fix [\#139](https://github.com/sapcc/elektra/pull/139) ([hgw77](https://github.com/hgw77))
- wizard fix [\#138](https://github.com/sapcc/elektra/pull/138) ([hgw77](https://github.com/hgw77))
- activate masterdata cockpit [\#137](https://github.com/sapcc/elektra/pull/137) ([hgw77](https://github.com/hgw77))
- fix test [\#136](https://github.com/sapcc/elektra/pull/136) ([hgw77](https://github.com/hgw77))
- Masterdata cockpit [\#135](https://github.com/sapcc/elektra/pull/135) ([hgw77](https://github.com/hgw77))
- Server floatingips [\#134](https://github.com/sapcc/elektra/pull/134) ([andypf](https://github.com/andypf))
- Networking refactoring [\#133](https://github.com/sapcc/elektra/pull/133) ([andypf](https://github.com/andypf))
- Session cookie path [\#132](https://github.com/sapcc/elektra/pull/132) ([andypf](https://github.com/andypf))
- sync projects when new project was created [\#131](https://github.com/sapcc/elektra/pull/131) ([hgw77](https://github.com/hgw77))
- Kubernikus [\#130](https://github.com/sapcc/elektra/pull/130) ([edda](https://github.com/edda))
- resource management: cleanup leftovers from Limes migration [\#129](https://github.com/sapcc/elektra/pull/129) ([majewsky](https://github.com/majewsky))   
This kills the old `ResourceManagement::{Service,Resource}Config` classes, so that Limes becomes the only source of truth for resource data and configuration.
- fix metric collection [\#127](https://github.com/sapcc/elektra/pull/127) ([databus23](https://github.com/databus23))   
The latest ruby prometheus client needs the label builder defined slightly different.
- Rails5 [\#124](https://github.com/sapcc/elektra/pull/124) ([andypf](https://github.com/andypf))
- Beautiful 404 errors [\#122](https://github.com/sapcc/elektra/pull/122) ([andypf](https://github.com/andypf))
- Audit Plugin [\#120](https://github.com/sapcc/elektra/pull/120) ([edda](https://github.com/edda))
- Add Maia's monitoring\_viewer role [\#119](https://github.com/sapcc/elektra/pull/119) ([jobrs](https://github.com/jobrs))   
which is end-user assignable \(permission to see tenant-metrics we have chosen to make available\)
- Bugfix resource management viewer [\#118](https://github.com/sapcc/elektra/pull/118) ([hgw77](https://github.com/hgw77))
- introduce new all-in-one misty cc gem [\#117](https://github.com/sapcc/elektra/pull/117) ([hgw77](https://github.com/hgw77))
- Use misty resource management v3 [\#116](https://github.com/sapcc/elektra/pull/116) ([hgw77](https://github.com/hgw77))
- Use misty resource management v3 [\#115](https://github.com/sapcc/elektra/pull/115) ([hgw77](https://github.com/hgw77))
- Use misty [\#114](https://github.com/sapcc/elektra/pull/114) ([andypf](https://github.com/andypf))
- DO NOT MERGE UNTIL WE HAVE THE GO -- Quick hack new fip network in EU-DE-1. Fix asap. [\#113](https://github.com/sapcc/elektra/pull/113) ([edda](https://github.com/edda))   
DO NOT MERGE YET. NETWORK IS NOT READY!
- Reduce object-store package size to 1GiB [\#112](https://github.com/sapcc/elektra/pull/112) ([reimannf](https://github.com/reimannf))
- Floating IPs comment [\#111](https://github.com/sapcc/elektra/pull/111) ([Carthaca](https://github.com/Carthaca))   
@edda FYI
- \[resource\_management\] bugfix in domain\_admin\_controller [\#110](https://github.com/sapcc/elektra/pull/110) ([andypf](https://github.com/andypf))   
@majewsky Please take a look. We discovered an error, if a service is not available then @domain.find\_resource returns nil and it bangs.
- \[shared\_filesystem\_Storage\] add CIFS protocoll to shares and add OU a… [\#109](https://github.com/sapcc/elektra/pull/109) ([andypf](https://github.com/andypf))   
…ttribute to security service
- Shares [\#108](https://github.com/sapcc/elektra/pull/108) ([andypf](https://github.com/andypf))
- \[compute\] add instance action tab to show for admins [\#107](https://github.com/sapcc/elektra/pull/107) ([Carthaca](https://github.com/Carthaca))   
admins get here from looking up directly, so can't trigger actions
- LBaaS: UI states and Default Pool change for Listeners [\#106](https://github.com/sapcc/elektra/pull/106) ([tlesmann](https://github.com/tlesmann))   
- Update Default Pool for Listeners \(Needed for Pool switch\).
- enable policy engine in js context [\#105](https://github.com/sapcc/elektra/pull/105) ([andypf](https://github.com/andypf))   
@edda FYI
- Remove monasca [\#104](https://github.com/sapcc/elektra/pull/104) ([hgw77](https://github.com/hgw77))
- show current resource usage in review request [\#103](https://github.com/sapcc/elektra/pull/103) ([hgw77](https://github.com/hgw77))   
!\[capture\]\(https://cloud.githubusercontent.com/assets/5598283/26624544/7e482706-45f1-11e7-8c8d-a6e58e599ed0.PNG\)
- Logon per domain [\#102](https://github.com/sapcc/elektra/pull/102) ([andypf](https://github.com/andypf))
- Add filter for request type, simplify and clean up view [\#101](https://github.com/sapcc/elektra/pull/101) ([edda](https://github.com/edda))
- \[cinder\] allow to reset volume attach\_status + hint [\#100](https://github.com/sapcc/elektra/pull/100) ([Carthaca](https://github.com/Carthaca))   
@andypf : Sorry! I knew this would come back to me - turned out to be very soon :\)
- update auth gem [\#99](https://github.com/sapcc/elektra/pull/99) ([andypf](https://github.com/andypf))
- add action reset volume status for volume admins [\#98](https://github.com/sapcc/elektra/pull/98) ([andypf](https://github.com/andypf))
- add domain\_name and project\_name [\#97](https://github.com/sapcc/elektra/pull/97) ([hgw77](https://github.com/hgw77))
- sort floating\_ips add search and ajax paginate functionality [\#96](https://github.com/sapcc/elektra/pull/96) ([andypf](https://github.com/andypf))
- Fake search for servers, dns and volumes [\#95](https://github.com/sapcc/elektra/pull/95) ([edda](https://github.com/edda))
- generic model attributes trimmer [\#94](https://github.com/sapcc/elektra/pull/94) ([ArtieReus](https://github.com/ArtieReus))
- async emptying for containers [\#93](https://github.com/sapcc/elektra/pull/93) ([hgw77](https://github.com/hgw77))   
\#\#\# emptying in process
- use ELEKTRA\_SSL\_VERIFY\_PEER to disable ssl\_verify\_peer in FOG [\#92](https://github.com/sapcc/elektra/pull/92) ([hgw77](https://github.com/hgw77))
- Resmgnt details sort cloudadmin [\#91](https://github.com/sapcc/elektra/pull/91) ([hgw77](https://github.com/hgw77))
- Resmgnt sync now [\#90](https://github.com/sapcc/elektra/pull/90) ([hgw77](https://github.com/hgw77))   
!\[resurce-management-sync\]\(https://cloud.githubusercontent.com/assets/5598283/25428660/beb6eee4-2a76-11e7-9823-add44c9447ad.PNG\)
- Two factor [\#89](https://github.com/sapcc/elektra/pull/89) ([andypf](https://github.com/andypf))
- Flash dismissible [\#88](https://github.com/sapcc/elektra/pull/88) ([ArtieReus](https://github.com/ArtieReus))
- Dns self service [\#87](https://github.com/sapcc/elektra/pull/87) ([andypf](https://github.com/andypf))
- \[dns\] add dns\_viewer and make policy more readable [\#86](https://github.com/sapcc/elektra/pull/86) ([Carthaca](https://github.com/Carthaca))   
reflect https://github.com/sapcc/openstack-helm/commit/f242605e111ec66aff1b4e2cc9132d19991d719d
- eu-nl-1 available [\#85](https://github.com/sapcc/elektra/pull/85) ([Carthaca](https://github.com/Carthaca))   
@urfuwo go?
- \[lookup\] add project lookup by uuid [\#84](https://github.com/sapcc/elektra/pull/84) ([Carthaca](https://github.com/Carthaca))   
add project view \(not as show action because it is already to deeply integrated\)
- \[compute\] add nova-compute service with dis-/enable [\#83](https://github.com/sapcc/elektra/pull/83) ([Carthaca](https://github.com/Carthaca))
- add lookup plugin [\#82](https://github.com/sapcc/elektra/pull/82) ([Carthaca](https://github.com/Carthaca))   
@edda / @andypf : FYI
- Resource management/sort details [\#81](https://github.com/sapcc/elektra/pull/81) ([hgw77](https://github.com/hgw77))
- broken FAQ link & removal of monitoring [\#80](https://github.com/sapcc/elektra/pull/80) ([urfuwo](https://github.com/urfuwo))
- fix for not working pagination [\#79](https://github.com/sapcc/elektra/pull/79) ([hgw77](https://github.com/hgw77))
- Monitoring/error handling [\#78](https://github.com/sapcc/elektra/pull/78) ([hgw77](https://github.com/hgw77))
- show api errors in cost control ui [\#77](https://github.com/sapcc/elektra/pull/77) ([andypf](https://github.com/andypf))
- make domain quotas binding [\#76](https://github.com/sapcc/elektra/pull/76) ([majewsky](https://github.com/majewsky))   
Whenever a domain admin adjusts project quotas, ensure that they cannot exceed their domain quota allocation.
- Floating ip tests [\#75](https://github.com/sapcc/elektra/pull/75) ([andypf](https://github.com/andypf))
- fix bug in create router dialog [\#74](https://github.com/sapcc/elektra/pull/74) ([andypf](https://github.com/andypf))
- Resource admins [\#73](https://github.com/sapcc/elektra/pull/73) ([andypf](https://github.com/andypf))
- updated link project request to FAQ [\#72](https://github.com/sapcc/elektra/pull/72) ([urfuwo](https://github.com/urfuwo))   
instead of to homepage of docu
- show ip availability in floating ip allocation dialog [\#71](https://github.com/sapcc/elektra/pull/71) ([andypf](https://github.com/andypf))
- add additional input fields in project request dialog [\#70](https://github.com/sapcc/elektra/pull/70) ([andypf](https://github.com/andypf))
- \[WIP\] adjust resmgmt policy.json for new resource\_admin/viewer roles [\#69](https://github.com/sapcc/elektra/pull/69) ([majewsky](https://github.com/majewsky))   
Do not merge unless @ruvr has rolled out the respective roles.
- added kubernetes to the powered by section. [\#68](https://github.com/sapcc/elektra/pull/68) ([urfuwo](https://github.com/urfuwo))
- Network readonly policy [\#67](https://github.com/sapcc/elektra/pull/67) ([Carthaca](https://github.com/Carthaca))   
@andypf: fyi
- Project wizard [\#66](https://github.com/sapcc/elektra/pull/66) ([andypf](https://github.com/andypf))
- \[resmgmt\] remove confusing dns records resource [\#65](https://github.com/sapcc/elektra/pull/65) ([Carthaca](https://github.com/Carthaca))   
Hi @majewsky, can you have a look and clean up the db afterwards please?
- WIP: handle backend failures better when trying to apply quotas [\#63](https://github.com/sapcc/elektra/pull/63) ([majewsky](https://github.com/majewsky))   
Please do not merge yet, I want to get rid of that `\<p class="alert alert-error" id="error\_message"\>` first.
- Project wizard [\#62](https://github.com/sapcc/elektra/pull/62) ([andypf](https://github.com/andypf))
- \[resmgmt\] fix manila usage [\#60](https://github.com/sapcc/elektra/pull/60) ([Carthaca](https://github.com/Carthaca))
- \[core\] extend base model with pretty time formatters [\#59](https://github.com/sapcc/elektra/pull/59) ([Carthaca](https://github.com/Carthaca))   
and make use of them
- Inquiries/handle delete project [\#58](https://github.com/sapcc/elektra/pull/58) ([hgw77](https://github.com/hgw77))
- add no delimiter option to format function [\#57](https://github.com/sapcc/elektra/pull/57) ([hgw77](https://github.com/hgw77))
- re-add .ruby-version with matching value from Dockerfile [\#56](https://github.com/sapcc/elektra/pull/56) ([Carthaca](https://github.com/Carthaca))   
and also run travis with this
- add new inital sync function [\#55](https://github.com/sapcc/elektra/pull/55) ([hgw77](https://github.com/hgw77))
- Lbaas lb state [\#54](https://github.com/sapcc/elektra/pull/54) ([tlesmann](https://github.com/tlesmann))   
Pull Load Balancer provisioning state in screens to make it visible to users because of long pending update cycles.
- Resource management/reduce quota [\#53](https://github.com/sapcc/elektra/pull/53) ([hgw77](https://github.com/hgw77))
- \[compute\] add host aggregates to cloud\_admin view [\#52](https://github.com/sapcc/elektra/pull/52) ([Carthaca](https://github.com/Carthaca))   
and improve hypervisor show
- \[manila\] policy … [\#51](https://github.com/sapcc/elektra/pull/51) ([Carthaca](https://github.com/Carthaca))   
reflect https://github.com/sapcc/openstack-helm/commit/14e9893021f4653feeb48a27a1b72ed5021c1ab2
- fix broken alarms list [\#50](https://github.com/sapcc/elektra/pull/50) ([hgw77](https://github.com/hgw77))
- Monitoring/fixes [\#49](https://github.com/sapcc/elektra/pull/49) ([hgw77](https://github.com/hgw77))
- Monitoring/fixes [\#48](https://github.com/sapcc/elektra/pull/48) ([hgw77](https://github.com/hgw77))
- \[dns\] add pools to cloud\_dns\_admin view [\#46](https://github.com/sapcc/elektra/pull/46) ([Carthaca](https://github.com/Carthaca))   
- fog-openstack bump
- Lbaas l7policies [\#45](https://github.com/sapcc/elektra/pull/45) ([tlesmann](https://github.com/tlesmann))   
UI implementation for LBaaS L7Policies and L7rules.
- bugfix: private images are not shown in server create dialog [\#44](https://github.com/sapcc/elektra/pull/44) ([andypf](https://github.com/andypf))
- handle friendly id after project update [\#43](https://github.com/sapcc/elektra/pull/43) ([andypf](https://github.com/andypf))
- Cinder policy [\#42](https://github.com/sapcc/elektra/pull/42) ([Carthaca](https://github.com/Carthaca))   
@andypf : FYI
- fix the label bug [\#41](https://github.com/sapcc/elektra/pull/41) ([hgw77](https://github.com/hgw77))
- do not validate project id on zone transfer request creation [\#40](https://github.com/sapcc/elektra/pull/40) ([andypf](https://github.com/andypf))
- \[compute\] compute\_cloud\_admin can view all instances [\#39](https://github.com/sapcc/elektra/pull/39) ([Carthaca](https://github.com/Carthaca))   
added pagination + owning project
- Dns transfer [\#38](https://github.com/sapcc/elektra/pull/38) ([andypf](https://github.com/andypf))
- Node install cloud init [\#37](https://github.com/sapcc/elektra/pull/37) ([ArtieReus](https://github.com/ArtieReus))   
@databus23 this is ready to merge... lets synch when we can do it.
- remove cost control from project creation [\#35](https://github.com/sapcc/elektra/pull/35) ([auhlig](https://github.com/auhlig))   
remove cost control from project creation workflow. please merge @majewsky @edda
- \[Readme\] add name origin [\#33](https://github.com/sapcc/elektra/pull/33) ([Carthaca](https://github.com/Carthaca))   
@edda ok with you or is there more to tell?
- check for cost object in payload [\#32](https://github.com/sapcc/elektra/pull/32) ([auhlig](https://github.com/auhlig))   
Added ll 3. Please merge if this looks reasonable to you @Carthaca .
- \[dns\] allow cloud\_dns\_admin to do zone update/delete at central place [\#31](https://github.com/sapcc/elektra/pull/31) ([Carthaca](https://github.com/Carthaca))   
@andypf : please have a look
- bugfix: cannot delete recordset [\#30](https://github.com/sapcc/elektra/pull/30) ([andypf](https://github.com/andypf))
- Compute attach interface [\#29](https://github.com/sapcc/elektra/pull/29) ([andypf](https://github.com/andypf))
- Only join match\_by in monitoring if it is an array [\#28](https://github.com/sapcc/elektra/pull/28) ([reimannf](https://github.com/reimannf))
- add selectbox for subnets in router create dialog [\#27](https://github.com/sapcc/elektra/pull/27) ([andypf](https://github.com/andypf))
- share policy: check for project scope [\#26](https://github.com/sapcc/elektra/pull/26) ([Carthaca](https://github.com/Carthaca))   
@andypf : and the last of its kind, please have a look
- remove unused extra policy\_default\_param [\#25](https://github.com/sapcc/elektra/pull/25) ([Carthaca](https://github.com/Carthaca))   
I could create an instance without these lines and without having a special nova role
- keypair policy: remove not necessary check [\#24](https://github.com/sapcc/elektra/pull/24) ([Carthaca](https://github.com/Carthaca))   
@andypf: please have a look
- fill policy with domain id for technical users [\#23](https://github.com/sapcc/elektra/pull/23) ([Carthaca](https://github.com/Carthaca))   
@andypf please have a look
- textual change. in case no floating IPs available. [\#22](https://github.com/sapcc/elektra/pull/22) ([bozinsky](https://github.com/bozinsky))   
Users are presented a dialog to create a floating ips, when floating IPs exhausted in the project.
- \[CCM-294\] put user in target for policy check [\#21](https://github.com/sapcc/elektra/pull/21) ([Carthaca](https://github.com/Carthaca))   
@andypf / @tlesmann : is it intended to be used this way?
- Reworking version of shares using Redux [\#20](https://github.com/sapcc/elektra/pull/20) ([andypf](https://github.com/andypf))
- \[identity\] add translation to role names [\#19](https://github.com/sapcc/elektra/pull/19) ([Carthaca](https://github.com/Carthaca))   
for more clarity we label the role names. most important for role `admin` to be identified as 'Keystone Admininistrator'
- \[networking\] add pagination to networks [\#17](https://github.com/sapcc/elektra/pull/17) ([Carthaca](https://github.com/Carthaca))   
the list for the cloud\_network\_admin is getting too long, so paginate
- better error messages [\#16](https://github.com/sapcc/elektra/pull/16) ([auhlig](https://github.com/auhlig))   
Does this look reasonable @edda ?
- disable cost\_control if catalog does not contain billing service [\#15](https://github.com/sapcc/elektra/pull/15) ([auhlig](https://github.com/auhlig))   
Will that work @edda ?
- enhance and reactivate cost control  [\#14](https://github.com/sapcc/elektra/pull/14) ([auhlig](https://github.com/auhlig))   
reactivate cost control, better error handling, some updates, bar chart currently disabled
- Read alarm's description from alarm API instead of alarm-definition API [\#13](https://github.com/sapcc/elektra/pull/13) ([dhague](https://github.com/dhague))   
 This allows us to show the alarm's description with template variables filled in by Monasca, and potentially avoids a call to the alarm-definition API.
- \[servers-icon\]: added experimental icon to the add one time root pass… [\#12](https://github.com/sapcc/elektra/pull/12) ([ArtieReus](https://github.com/ArtieReus))   
…word button
- allow to allocate floating ip in subnet [\#11](https://github.com/sapcc/elektra/pull/11) ([andypf](https://github.com/andypf))
- catch SecurityViolation Errors. Add User Profile View [\#10](https://github.com/sapcc/elektra/pull/10) ([andypf](https://github.com/andypf))   
@edda Please take a look
- don't raise on router without external gateway [\#9](https://github.com/sapcc/elektra/pull/9) ([Carthaca](https://github.com/Carthaca))   
@andypf : FYI
- Manila [\#8](https://github.com/sapcc/elektra/pull/8) ([andypf](https://github.com/andypf))
- dns: activate zone actions for cloud dns admin \(create, edit, delete\) [\#6](https://github.com/sapcc/elektra/pull/6) ([andypf](https://github.com/andypf))
- add show share view to shared\_filesystem\_storage [\#5](https://github.com/sapcc/elektra/pull/5) ([andypf](https://github.com/andypf))
- Add Dockerfile [\#3](https://github.com/sapcc/elektra/pull/3) ([databus23](https://github.com/databus23))   
This adds a public Dockerfile \(and docker-compose.yml\)
- reflect stricter nova policy [\#2](https://github.com/sapcc/elektra/pull/2) ([Carthaca](https://github.com/Carthaca))   
This way you don't get the ugly backend error, if you don't have permissions to view the instance list - but it hides the fact that you don't see them out of missing permissions
- Fix small typo in README [\#1](https://github.com/sapcc/elektra/pull/1) ([preillyme](https://github.com/preillyme))   
Small edit to fix a typo in the README file.



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*