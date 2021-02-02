# Restart

This script is designed to restart DL_POLY simulations - enabling simulations to be run over multiple jobs.

# This script:

1. Creates consecutively numbered directories (save$numdir), copies and zips the relevant files into the directories
2. Edits the CONTROL file to enable the simulation to restart from a previous simulation 
3. Runs the relevant job submission script
4. Calculates the progress of the overall simulation


## Notes:

This script is designed to submit jobs to the Bath HPC. 
To restart DL_POLY simulations on any HPC please change the name of the job submission script on line 86.

* Line 86:

```
sbatch run.dlc
```

