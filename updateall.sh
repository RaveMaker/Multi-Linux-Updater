#!/bin/bash

# Update multiple Linux OS Distributions from a single server
#
# by RaveMaker & ET
# http://ravemaker.net
# http://etcs.me

# log and updateall.lst files by default should be inside one workdir.
# by default workdir is the script dir
workdir="`dirname \"$0\"`"
workdir="`( cd \"$workdir\" && pwd )`"
if [ -z "$workdir" ] ; then
    # error; for some reason, the path is not accessible
    # to the script (e.g. permissions re-evaled after suid)
    exit 1  # fail
fi

# temporary log file while script is running.
# you can set to other place manually, ex: logfile=/var/logs/updateall.log
logfile=$workdir/updateall.run
# list of server to update.
# you can set to other place manually, ex: listfile=/var/myfiles/servers.lst
listfile=$workdir/updateall.lst

# You can set finallogfolder to a foldername ("logs" for example)
# to generate all logs inside that
# for example:
# finallogfolder=$workdir/logs
# note: you need to manually create that folder
finallogfolder=$workdir
# final log file
finallogfile=$finallogfolder/update-$(date +%y%m%d)

# Check if the script is still running
cd $workdir/
if [ -a $logfile ] ; then
    echo ""
    echo "Script Is Running! check " $logfile
    echo ""
    exit;
fi

# Start Logging
(
echo " Starting update process..." $(date +%y%m%d)
echo ""
cat $listfile | while read line
do
    dist=$(echo $line | awk '{print $NF}')
    case $dist in
	'CentOS'|'RHEL'|'OracleLinux')
	    server="$(echo $line | awk '{print($(NF-2))}')"
	    port="$(echo $line | awk '{print($(NF-1))}')"
	    echo $server " " $dist
	    ssh -n -l root -p $port $server 'yum-complete-transaction -y; yum update -y -y'
	;;
        'Solaris')
	    server="$(echo $line | awk '{print($(NF-2))}')"
	    port="$(echo $line | awk '{print($(NF-1))}')"
            echo ""
            echo "**************************************"
            echo "***** " $server " " $dist
            echo "**************************************"
            echo ""
            ssh -n -l root -p $port $server '/opt/csw/bin/pkgutil -U; /opt/csw/bin/pkgutil -u'
        ;;
	'Debian'|'Ubuntu')
	    server="$(echo $line | awk '{print($(NF-2))}')"
	    port="$(echo $line | awk '{print($(NF-1))}')"
	    echo $server " " $dist
	    ssh -n -l root -p $port $server 'apt-get update -y'
	    ssh -n -l root -p $port $server 'apt-get upgrade -y'
	;;
	*)
	    echo "Unknown Linux Distribution"
	;;
    esac
done
echo ""
echo "All Done."
) 2>&1 | tee -a $logfile

mv $logfile $finallogfile
rm -f /var/spool/mail/root

