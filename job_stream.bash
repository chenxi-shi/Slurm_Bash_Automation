#!/bin/bash

### The working directory, may change it to the dir you want
dir="/gss_gpfs_scratch/shi.che/test_task_stream"

### queue name for job execute on, may change it to the queue you want
queue="ser-par-10g-3"
### num of cpu for node in the queue
cpu_count=40

### time you predict your job will spends, default is one day
### in minutes in this case, hh:mm:ss 
spend_time="40:00"

### The number of jobs running simultaneously, may change it to job you want to exe sumultaneously
number_of_job=3

job=1

while [ $job -le $number_of_job ]
do
	job_dir="Job`printf %04d $job`"
	mkdir $job_dir

	################ 1. for tandem #####################
	job_name_tandem="Job`printf %04d $job`_tandem"

	file="./$job_dir/$job_name_tandem.bash"
	
	### write a batch script for tandem job
	echo "#!/bin/bash" >> $file
	echo "#SBATCH --job-name=$job_name_tandem" >> $file
	echo "#SBATCH --output=$job_name_tandem.out" >> $file
	echo "#SBATCH --error=$job_name_tandem.err" >> $file
	echo "#SBATCH --time=$spend_time" >> $file
	echo "#SBATCH -n $cpu_count" >> $file
	echo "#SBATCH --exclusive" >> $file
	echo "#SBATCH --partition=$queue" >> $file
	echo "#SBATCH -D $dir/$job_dir" >> $file
	echo "work=$dir/$job_dir" >> $file
	echo "cd \$work" >> $file
	# echo "tandem /gss_gpfs_scratch/ali.b/xtandem/1/input1.xml" >> $file
	echo "python $dir/tandem`printf %01d $job`.py" >> $file
	### submit tandem job into cluster
	RES=$(sbatch $file)
	# sbatch $file
	
	################# 2. for Tandem2XML ###################
	job_name_Tandem2XML="Job`printf %04d $job`_Tandem2XML"
	file="./$job_dir/$job_name_Tandem2XML.bash"
	
	### write a batch script for Tandem2XML job
	echo "#!/bin/bash" >> $file
	echo "#SBATCH --job-name=$job_name_Tandem2XML" >> $file
	echo "#SBATCH --output=$job_name_Tandem2XML.out" >> $file
	echo "#SBATCH --error=$job_name_Tandem2XML.err" >> $file
	echo "#SBATCH --time=$spend_time" >> $file
	echo "#SBATCH -n $cpu_count" >> $file
	echo "#SBATCH --exclusive" >> $file
	echo "#SBATCH --partition=$queue" >> $file
	echo "#SBATCH -D $dir/$job_dir" >> $file
	
	echo "work=$dir/$job_dir" >> $file
	echo "cd \$work" >> $file
	# echo "Tandem2XML /gss_gpfs_scratch/ali.b/xtandem/1/1607011A_NC20A_10ul_180min.tandem.xml /gss_gpfs_scratch/ali.b/xtandem/1/1607011A_NC20A_10ul_180min.tandem.pep.xml" >> $file
	echo "python $dir/Tandem2XML`printf %01d $job`.py" >> $file
	### submit Tandem2XML job into cluster
	echo "$RES"
	RES=$(sbatch --dependency=afterok:${RES##* } $file)
	
	################# 3. for PeptideProphetParser ###################
	job_name_PeptideProphetParser="Job`printf %04d $job`_PeptideProphetParser"
	file="./$job_dir/$job_name_PeptideProphetParser.bash"
	
	### write a batch script for PeptideProphetParser job
	echo "#!/bin/bash" >> $file
	echo "#SBATCH --job-name=$job_name_PeptideProphetParser" >> $file
	echo "#SBATCH --output=$job_name_PeptideProphetParser.out" >> $file
	echo "#SBATCH --error=$job_name_PeptideProphetParser.err" >> $file
	echo "#SBATCH --time=$spend_time" >> $file
	echo "#SBATCH -n $cpu_count" >> $file
	echo "#SBATCH --exclusive" >> $file
	echo "#SBATCH --partition=$queue" >> $file
	echo "#SBATCH -D $dir/$job_dir" >> $file
	
	echo "work=$dir/$job_dir" >> $file
	echo "cd \$work" >> $file
	# echo "PeptideProphetParser /gss_gpfs_scratch/ali.b/xtandem/1/1607011A_NC20A_10ul_180min.tandem.pep.xml ACCMASS PPM NOICAT MINPROB=0.05" >> $file
	echo "python $dir/PeptideProphetParser`printf %01d $job`.py" >> $file
	### submit PeptideProphetParser job into cluster
	echo "$RES"
	RES=$(sbatch --dependency=afterok:${RES##* } $file)
	
	# ################# 4. for spectrast ###################
	# job_name_spectrast="Job`printf %04d $job`_spectrast"
	# file="./$job_dir/$job_name_spectrast.bash"
	
	# ### write a batch script for spectrast job
	# echo "#!/bin/bash" >> $filerm 
	# echo "#SBATCH --job-name=$job_name_spectrast" >> $file
	# echo "#SBATCH --output=$job_name_spectrast.out" >> $file
	# echo "#SBATCH --error=$job_name_spectrast.err" >> $file
	# echo "#SBATCH --time=$spend_time" >> $file
	# echo "#SBATCH -n $cpu_count" >> $file
	# echo "#SBATCH --exclusive" >> $file
	# echo "#SBATCH --partition=$queue" >> $file
	# echo "#SBATCH -D $dir/$job_dir" >> $file
	
	# echo "work=$dir/$job_dir" >> $file
	# echo "cd \$work"
	# echo "spectrast -cN/gss_gpfs_scratch/ali.b/xtandem/1/1607011A_NC20A_10ul_180min.splib -cP0.5 /gss_gpfs_scratch/ali.b/xtandem/1/1607011A_NC20A_10ul_180min.tandem.pep.xml" >> $file
	# ### submit spectrast job into cluster
	# echo "$RES"
	# sbatch --dependency=afterok:${RES##* } $file

	
	let job++
done