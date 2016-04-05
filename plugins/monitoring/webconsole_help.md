### Available Clients
* monasca

### Quick Help
`monasca --help`
Lists the commands and options of the Monasca client

`monasca metric-name-list`
Lists all the metrics that are currently reported by [Monasca agents](https://github.com/sapcc/monasca-agent/blob/master/README.rst)  

`monasca metric-list --name disk.space_used_perc`
Lists all distinct measurement series for a metric

`monasca alarm-definition-create disk-full "avg(disk.space_used_perc{service=object-store}, 900) > 90"`
Triggers an alarm in case disks used by service *object-store* have been >90% full over the last 15 minutes 

`monasca alarm-list --state ALARM --sort-by "severity desc"`
Lists alarms that are in active state

For details see the [Monasca CLI documentation](https://github.com/sapcc/python-monascaclient/blob/master/README.rst#command-line-api).

