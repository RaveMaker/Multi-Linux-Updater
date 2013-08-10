#!/bin/bash

# log and updateall.lst files by default should be inside one workdir.
# by default workdir is the script dir
workdir="`dirname \"$0\"`"
workdir="`( cd \"$workdir\" && pwd )`"
if [ -z "$workdir" ] ; then
    # error; for some reason, the path is not accessible
    # to the script (e.g. permissions re-evaled after suid)
    exit 1  # fail
fi
# you can set to other place manually
logfile=$workdir/updateall.run
# you can set to other place manually
listfile=$workdir/updateall.lst
finallogfile=$workdir/update-$(date +%y%m%d)

(
cd $workdir/
if [ -a $logfile ] ; then
    echo ""
    echo "Script Is Running! check " $logfile
    echo ""
    exit; 
fi

echo "**************************************"
echo "* Starting update process..." $(date +%y%m%d) "*"
echo "**************************************"
cat $listfile | while read line
do
    dist=$(echo $line | awk '{print $NF}')
    case $dist in
	'CentOS'|'RHEL')
	    server=$(echo $line | awk '{print($(NF-2))}')
	    port=$(echo $line | awk '{print($(NF-1))}')
	    echo ""
	    echo "**************************************"
	    echo "***** " $server " " $dist
	    echo "**************************************"
	    echo ""
	    ssh -n -l root -p $port $server 'yum-complete-transaction -y; yum update -y -y'
	;;
	'Debian'|'Ubuntu')
	    server=echo $line | awk '{print($(NF-2))}'
	    port=echo $line | awk '{print($(NF-1))}'
	    echo ""
	    echo "**************************************"
	    echo "*   " $server " " $dist "    *"
	    echo "**************************************"
	    echo ""
	    ssh -n -l root -p $port $server 'apt-get update -y'
	    ssh -n -l root -p $port $server 'apt-get upgrade -y'
	;;
	*)
	    echo "**************************************"
	    echo "*     Unknown Linux Distribution     *"
	    echo "**************************************"
	    echo ""
	;;
    esac
done
echo ""
echo "**************************************"
echo "*****           All Done         *****"
echo "**************************************"
echo ""
) 2>&1 | tee -a $logfile

mv $logfile $finallogfile
rm -f /var/spool/mail/root
