### Available Clients
* lyra

### Quick Help
[Automation command line tool documentation](https://localhost/docs/automation/cli.html)

`lyra --help`
Show help

### Most Used Commands
`lyra authenticate --identity-endpoint={endpoint} --username={name} --user-domain-name={name} --project-name={name} --project-domain-name={name}}`
Get an authentication token and automation and arc endpoints

`lyra automation list`
Get all available automations

`lyra automation show --automation-id={id}`
Show a specific automation

`lyra automation execute --automation-id={id} --selector={selector}`
Executes an exsiting automation

`lyra run show --run-id={id}`
Show a specific automation run

`lyra job show --job-id={id}`
Shows an especific job