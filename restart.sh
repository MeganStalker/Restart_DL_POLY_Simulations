#!/bin/bash

# Script 1/1

######################
## By Megan Stalker ##
######################

# This script is designed to restart DL_POLY simulations - enabling simulations to be run over multiple jobs.

# This script:

# 1. Creates consecutively numbered directories (save$numdir), copies and zips the relevant files into the directories
# 2. Edits the CONTROL file to enable the simulation to restart from a previous simulation 
# 3. Runs the relevant job submission script
# 4. Calculates the progress of the overall simulation

################
# RESTART INFO #
################

# Checks for the REVCON file in the parent directory to ensure restart info is present
# If the REVCON file is not present, the script will not run

if [ -e REVCON ]
then

###############
# DIRECTORIES #
###############

# Counts the number of "save" directories in the parent directory

	numdir=$(ls -d */ | grep save | wc -l | awk '{ print $1 }')
	echo "numdir" $numdir

# Creates a new directory corresponding the number of "save" directories in the parent directory
# The first "save" directory will be named "save0"

	mkdir save$numdir

# Moves the DL_POLY files into the created directory

	mv CONFIG save$numdir
	mv OUTPUT save$numdir
	mv REVOLD save$numdir
	mv RDFDAT save$numdir
	mv STATIS save$numdir
	mv HISTORY save$numdir
	mv REVCON CONFIG
	mv REVIVE REVOLD

# Copies any DL_POLY files needed to run the next simulation (to ensure they remain in the parent directory)
        	
	cp CONTROL save$numdir
	cp REVIVE save$numdir
	cp SOLVAT save$numdir

################
# CONTROL FILE #
################

# Edits the CONTROL file to enable the simulation to restart from the previous simulation

	cp CONTROL ./CONTROL_tmp

	sed -e 's/#restart/restart/' -e 's/#RESTART/RESTART/' -e 's/RESTART SCALE/RESTART/' -e 's/restart scale/restart/' CONTROL_tmp >> CONTROL_temp

	mv CONTROL_temp CONTROL
	rm CONTROL_tmp

###########
# ZIPPING #
###########

# Zips the files in the created directory

	gzip -v save$numdir/*

##################
# JOB SUBMISSION #
##################

# Submits the restarted simulation to the job queue

	sbatch run.dlc

##################################################
# CALCULATES THE PROGRESS THROUGH THE SIMULATION #
##################################################

# Calculates the current percent progress through the simulation

	gunzip save$numdir/STATIS


	marker=$(grep -A1 " ENERGY UNITS" save$numdir/STATIS  | grep -v " ENERGY UNITS" | awk '{print $3}')
	total=$(grep "steps" CONTROL | awk '{print $2}')
	final=$(grep "        $marker" save$numdir/STATIS | tail -n 1 | awk '{print $1}')
	maths=$((($final*100)/$total))
	echo $maths"% through the simulation"
	gzip save$numdir/STATIS

else
   echo "REVCON not found - hence no restart info"
fi

