Particle migration analysis
======

Recently developed classification methods have enabled resolving multiple biological structures from cryo-EM data collected on heterogeneous biological samples. However, there remains the problem of how to base the decisions in the classification on the statistics of the cryo-EM data, to reduce the subjectivity in the process. Here, we propose a quantitative analysis to determine the iteration of convergence and the number of distinguishable classes, based on the statistics of the single particles in an iterative classification scheme. We start the classification with more number of classes than anticipated based on prior knowledge, and then combine the classes that yield similar reconstructions. The classes yielding similar reconstructions can be identified from the migrating particles (jumpers) during consecutive iterations after the iteration of convergence. We therefore termed the method “jumper analysis”, and applied it to the output of RELION 3D classification of a benchmark experimental dataset. This work is a step forward toward fully automated single-particle reconstruction and classification of cryo-EM data.


http://franklab.cpmc.columbia.edu/franklab/wp-content/uploads/2014/08/JumperAnalysis.zip 
Last updated Oct 20, 2014

###Introduction
This MATLAB code package is used to load RELION (Scheres, J Struct Biol. 2012) output files and perform the jumper analysis.

###Requirements
MATLAB v9.0 and above.

###Installation
Download and decompress the package.
Copy the folder *JumperCode/* to your local working directory.
Add the folder path to your MATLAB directory.
To run the jumper analysis, call the main function in the MATLAB command window:
```>> main```
Note that it might take several minutes to load data, depends on the size of the available RAM and input files.

###Please Cite
If you find the package useful, please cite:

B. Chen, B. Shen, and J. Frank. Particle migration analysis in iterative classification of cryo-EM single-particle data. J Struct Biol. 2014 

###Maintainers
Bingxin Shen: bs2733@columbia.edu or bingxin.shen@gmail.com
