Relion
======

###Scripts for Relion 1.2

#####exclude_bad_classes_relion

You may use the following script to remove bad 2D (or 3D) classes from your dataset. It will clean up your star file, removing particles from bad classes.

The input parameters are:

* PLT file containing the bad class numbers (one number per line)
* Data STAR file containing the last CL2D/CL3D iteration you want to clean up
* Name of the output star file

---
#####plot_classes

You may use the following script to plot particle distribution inside 2D classes from your dataset. The script also prints min,max and average number of particles over all classes. It will use the data star file after successfull 2D classification.

The input parameter is:

* Data STAR file containing the last CL2D iteration

---
