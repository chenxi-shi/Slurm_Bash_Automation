#!/bin/bash

### The working directory, change it to the your dir
dir="/gss_gpfs_scratch/lock.j/matlab"

### partition name for job execute on, may change it to the partition you want
partition="ser-par-10g-3"
### number of nodes to distribute n tasks across
node_count=1

### time you predict your job will spends, default is one day
### in minutes in this case, hh:mm:ss
spend_time="23:00:00"

### The number of jobs running simultaneously, you may change it
job_concurrent_num=16

job_dir="bash_files"
mkdir -p $job_dir
output_dir="sbatch_output"

### change to your dir file
dir_text_file="MovieInfo.txt"

process_id=0
movie_counter=0
printf "${job_id_array[1]}"

cat $dir_text_file | while read directory
do
        echo "$directory"
        ((movie_counter=movie_counter+1))
        ((process_id=process_id+1))

        dir_array=(${directory//// })
        # echo "${#dir_array[@]}"
        job_name=${dir_array[${#dir_array[@]}-1]}

        batch_file="$dir/$job_dir/$job_name.bash"

        ### write a batch script for tandem job
        printf "#!/bin/bash\n" > $batch_file
        printf "#SBATCH --job-name=$job_name\n" >> $batch_file
        printf "#SBATCH --output=$output_dir/$job_name.out\n" >> $batch_file
        printf "#SBATCH --error=$output_dir/$job_name.err\n" >> $batch_file
        printf "#SBATCH --time=$spend_time\n" >> $batch_file
        printf "#SBATCH --exclusive\n" >> $batch_file
        printf "#SBATCH --partition=$partition\n" >> $batch_file
        printf "#SBATCH -N $node_count\n" >> $batch_file
        printf "#SBATCH -D $dir\n\n" >> $batch_file
        printf "work=$dir\n" >> $batch_file
        printf "cd \$work\n" >> $batch_file
        #printf "python $dir/$job_name\n" >> $batch_file   ### For test
        printf "matlab -r \"MovieOperations_skiptofewNo2_2UC_bash($movie_counter); quit\" -nodisplay\n" >> $batch_file

        echo $process_id
        if [ "$movie_counter" -le "$job_concurrent_num" ]; then
                RES=$(sbatch $batch_file)
                echo $RES
        else
                echo ${job_id_array[process_id]}
#               RES=$(sbatch --dependency=afterok:${job_id_array[process_id]} $batch_file)
                RES=$(sbatch --dependency=afterany:${job_id_array[process_id]} $batch_file)
                echo $RES
        fi
        job_id_array[process_id]=${RES##* }

        if [ "$process_id" -eq "$job_concurrent_num" ]; then
                process_id=0
        fi

done
