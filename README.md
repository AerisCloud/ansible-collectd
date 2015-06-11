collectd role
===============

This role takes care of adding collectd to any given server.

It can be used to:

1. Collect metrics about a machines, and optionally forward them to an aggregation machine.

2. Create an aggregation machine, which will receive the metrics from a given set of machine within the same datacenter.
   In this case too, metrics can optionally be forwarded to another service.

Configuration
--------------

### For any machines

Simply add the collector role to your playbook.

By default, we will save all metrics to RRD files under `/var/lib/collectd/rrd/${hostname}`.

### For forwarding machines

#### Inventory

Normally, we put all aggregation on a single machine.
However, it is possible to decouple them, and provision separate machines for any aggregators we might have.
This example demonstrate how to create a dedicated collectd aggregator.

```ini
[collectd:children]
collectd-somedc-prod

[collectd-somedc-prod]
collectd1.somedc.prod         ansible_ssh_host=10.0.1.111

[... skipping ...]
[somedc-prod:children]
collectd-somedc-prod

[somedc-prod:vars]
collectd_forwarder = collectd1.somedc.prod

#
# Optional: if you are aggregating logs with logstash
# and are using ElasticSearch and Kibana, you might
# want to also keep track of your metrics through
# Kibana. If so, simply add the following to your
# global configuration - keep in mind that
# activating this will turn off any other
# forwarding you might have configured in
# favor of sending all entries to logstash
#
logstash_forwarder = collectd2.somedc.prod

collectd_forward_to_logstash = true
```

The following may also be added to your inventory.

* `collectd_interval`: at what interval in seconds to take measurements (default: 60)
* `check_disk`: a value which we will use to select what disk to monitor (default: xvde)
* `fs_type`: the file system type to monitor (default: ext4)
* `monitor_coretemp`: set to true if you want to monitor coretemp (only useful on real hardware)

### Roles addition

It is possible for any roles to add their own custom metric collection configuration.

In `myrole/templates/collectd.conf.j2`:

```
<Plugin "whatever">
    ...
</Plugin>
```

Then, in `myrole/tasks/main.yml`:

```yaml
- name: Adding collectd monitoring for myrole
  template: >
    src=collectd.conf.j2
    dest=/etc/collectd.d/myrole.conf
  notify:
    - Restart collectd
  tags:
    - myrole
    - files
    - collectd
```

### Execution

#### For any machines

Simply follow the standard provisioning method.

### For the collector machine

When provisioning with this role, you can also add
[Librato](https://www.librato.com/) and
[Graphite](http://graphite.wikidot.com/) support.

As you should not add any credentials to your inventory,
it should be done by using `--extra-vars` as described below.

#### Librato 

```
--extra-vars="use_librato=true" \
--extra-vars="librato_email=some@email.com" \
--extra-vars="librato_token=API-KEY"
```

### Graphite

```
--extra-vars="use_graphite=true" \
--extra-vars="graphite_host=some.host.com" \
--extra-vars="graphite_port="
```

See also
--------

* [collectd](http://collectd.org/)
