# Usage

```bash
run.sh CUCUMBER_PROFILE CCTEST_USER CCTEST_PASSWORD CCTEST_PROJECT CAPYBARA_APP_HOST ELEKTA_PATH*
```

ELEKTA_PATH default = /workspace/elektra/

## run e2e tests against elektra running on remote host

```bash
./run.sh e2e TEST_TM "XXXX" member https://elektra.corp
./run.sh admin TEST_TA "XXXX" admin https://elektra.corp
```

## run e2e in workspaces with running elektra env localhost

```bash
./run.sh e2e TEST_TM "XXXX" member
./run.sh admin TEST_TA "XXXX" admin
```

## run e2e from darwin running elektra locally on port 3000

```bash
./run.sh ./run.sh e2e TEST_TM "XXXX" member http://host.docker.internal:3000
./run.sh ./run.sh admin TEST_TA "XXXX" admin http://host.docker.internal:3000
```
