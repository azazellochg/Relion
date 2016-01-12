Relion
======

###Scripts for Relion 1.2+

#####JumperAnalysis

This MATLAB package provides a quantitative analysis to determine the iteration of convergence and the number of distinguishable classes, based on the statistics of the single particles in an iterative classification scheme, as used by Relion 3D classification.

---

#####exclude_bad_classes_relion

You may use the following script to remove bad 2D (or 3D) classes from your dataset. It will clean up your star file, removing particles from bad classes.

The input parameters are:

* PLT file containing the bad class numbers (one number per line)
* Data STAR file containing the last CL2D/CL3D iteration you want to clean up
* Name of the output star file

---
#####make_star_for_ptcl_sort

This script will extract coordinates of all particles from gempicker output and convert them to box format, then remove bad particles (not extracted in relion) and create a data star file for particle sorting according to picking references.

*Protocol:*

0. Do CTF correction and preliminary 2D classification in Relion to generate 2D references for autopicking
1. Run gempicker using 2D class average references from relion (do not renumber them!), rescale box files, remove particles too close to the border (use change_box script)
2. Extract particles in relion, creating data star file
3. Run this script, it will add reference-related columns to input star file
4. Run particle sorting in relion, remove particles with too low/high Z-score

---
#####plot_classes

You may use the following script to plot particle distribution inside 2D classes from your dataset. The script also prints min,max and average number of particles over all classes. It will use the data star file after successfull 2D classification.

The input parameter is:

* Data STAR file containing the last CL2D iteration

---
#####remove_bad_img.sh

Sometimes for negative stain "remove dust" options in relion are not working properly, creating strange pattern of dots. Here the script will use IMAGIC to remove images with extremely low/high pixel densities. Particles order should be the same in imagic stack and corresponding star file!
