# CDP Utils
This repo contains some utility scripts to apply on top of the very useful CDP Public automation ([cdp_one_click](https://github.com/paulvid/cdp-one-click)).

### Prereqs
You need to have the AWS CLI already configured.

### Tag the AWS resources of a CDP publiv env
The automation ([cdp_one_click](https://github.com/paulvid/cdp-one-click)) creates the AWS resources naming them after the environment prefix:
* EC2 instance names: `<prefix>-cdp-env*`
* Dynamo DB table: `<prefix>-cdp-table`

The script `cdp_tag_aws_resources.sh` adds/modifies the specified tag for:
- EC2 instances
- EBS volumes
- Dynamo DB table

Usage:
```
cdp_tag_aws_resources.sh <prefix> <tag_name> <tag_value>
```

The value of `<prefix>` must be the same specified in the cdp-one-click automation ([configuration file](https://github.com/paulvid/cdp-one-click#detailed-format))
