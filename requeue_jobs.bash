
#!/usr/bin/env bash

USAGE() # use "-h" to get this help
{
cat << EOF
usage: $0 options
./requeue_jobs -u <username>

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

job_id=($(squeue -l -u $user_name | awk '$1~/^[0-9]+$/ && $9=="(job requeued in held state)" {print $1}'))  # job_id is an array
#job_id=($(squeue -l -u $user_name | awk '$1~/^[0-9]+$/ && $9=="compute-2-135" {print $1}'))  # job_id is an array
echo "Job count: ${#job_id[@]}"

BRANCH_REGEX="^JobName=.*$"
for job in "${job_id[@]}"
do
    job_detail=$(scontrol show job $job)
    for item in $job_detail
    do
        if [[ $item =~ $BRANCH_REGEX ]]
        then
            #echo $item
            arrIN=(${item//JobName=/ })
            job_name=${arrIN[${#arrIN[@]}-1]}
            break
        fi
    done
    echo "$job  $job_name"
    # scancel $job
    # sbatch /gss_gpfs_scratch/$user_name/matlab/bash_files/$job_name.bash
done
