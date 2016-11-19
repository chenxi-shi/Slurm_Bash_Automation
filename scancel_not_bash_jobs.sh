#!/usr/bin/env bash

USAGE() # use "-h" to get this help
{
cat << EOF
usage: $0 options
./scancel_not_bash_jobs -u <username>

REQUIRED:
-u <username> The account name
EOF
}

while getopts p:o:n:u:i: args
do
	case $args in
	    u) # get user id
	        user_name=$OPTARG
	        printf "User: $user_name\n"
	        ;;
	    *) # input is wrong
	        USAGE
	        exit 1
	        ;;
 	esac
done

job_id=($(squeue -l -u $user_name | awk '$1~/^[0-9]+$/ && $3!="bash" {print $1}'))  # job_id is an array
echo "Job count: ${#job_id[@]}"
squeue -l -u $user_name | awk '$1~/^[0-9]+$/ && $3!="bash" || NR==2 {printf "%-15s %-20s\n", $1, $3}'  # output for checking

for job in "${job_id[@]}"
do
    echo "Cancel job $job"
#    scancel $job
done

squeue -l -u $user_name
