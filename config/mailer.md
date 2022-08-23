This guide explains how to setup cronus to be used in rails action mailer.

## Setup

### Technical user

1. The technical user `dashboard` hast to own the role `email_user` in all the regions where cronus should be used and within the domain `ccadmin` and project `master`. We decide to use seeds in this case. See this commit for more information:
   https://github.com/sapcc/helm-charts/commit/c5b26a6244ddc3de953ff1a71b6ee00929af82e5
2. Deploy elektra in all regions where cronus should be used so the new seed configuration can be applyed.
3. To check if the seeder had any error when rolling out the changes check the logs from the seeder pod in the right region.

   Example:

   ```bash
   kubectl config use context qa-de-1
   kubectl -n monsoon3 get pods
   kubectl -n monsoon3 logs openstack-seeder-76db46b59-dqjxc
   ```

4. Setup a webshell with following envs opening the dashboard in the right region:

   Unset following env variable:

   ```bash
   unset OS_AUTH_TYPE
   unset OS_AUTH_TOKEN
   unset OS_TOKEN
   ```

   And be sure you have set following env variable:

   ```bash
   export OS_PROJECT_DOMAIN_NAME=ccadmin
   export OS_USERNAME=dashboard
   export OS_USER_DOMAIN_NAME=default
   export OS_PROJECT_NAME=cloud_admin
   export OS_PASSWORD=<password>
   ```

5. Check that the dashboard user has the role `email_user` in each region where cronus will be used:

   ```bash
   os role assignment list --project=master --role=email_user
   ```

6. Create ec2 credentials for the dashboard user in each region where cronus will be used:

   ```bash
   os ec2 credentials create --project=master
   ```

7. Retrieve the credentials to be saved in vault afterwards

   ```bash
   OS_PROJECT_NAME=master cronuscli smtp credentials
   ```

## Testing with telnet

1. Create a file with following content and following name `smtp-test-login.txt`

   ```text
   EHLO cloud.sap
   AUTH LOGIN
   <ec2 user name>
   <ec2 user password>
   MAIL FROM: noreply+dashboard@email.global.cloud.sap
   RCPT TO: some.real.email@some.real.domain
   DATA
   From: Sender name <noreply+dashboard@email.global.cloud.sap>
   To: some.real.email@some.real.domain
   Subject: Telnet test

   This message was sent from elektra
   .
   QUIT
   ```

2. Run following command from your terminal

   ```bash
   openssl s_client -crlf -quiet -connect smtp.server.address:465 < smtp-test-login.txt
   ```
