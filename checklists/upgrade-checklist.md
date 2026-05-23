# Cloudera CDP Upgrade Checklist

## T-7 Days (1 Week Before)
- [ ] Review Cloudera upgrade documentation for target version
- [ ] Check OS and JDK compatibility matrix
- [ ] Run pre-upgrade check script: `./scripts/pre-upgrade-check.sh`
- [ ] Backup Cloudera Manager database (PostgreSQL/MySQL)
- [ ] Backup HDFS metadata (`hdfs dfsadmin -saveNamespace`)
- [ ] Take VM snapshots of all CM and master nodes
- [ ] Notify stakeholders of maintenance window

## T-1 Day
- [ ] Verify disk space: /opt, /var, /tmp all > 30% free
- [ ] Stop all Oozie/Spark streaming jobs
- [ ] Disable alerts to avoid noise during upgrade
- [ ] Download target parcel in advance

## Upgrade Day
- [ ] Run pre-upgrade check one more time
- [ ] Take fresh backup of CM DB
- [ ] Upgrade Cloudera Manager first
- [ ] Upgrade CDH parcels (download → distribute → activate)
- [ ] Perform rolling restart via CM
- [ ] Run post-upgrade verification script

## Post-Upgrade
- [ ] Verify all services STARTED + health GOOD
- [ ] Run sample Hive/Impala/Spark queries
- [ ] Check HDFS replication factor
- [ ] Re-enable monitoring alerts
- [ ] Update runbooks with new version info
- [ ] Delete old parcels to reclaim disk space
