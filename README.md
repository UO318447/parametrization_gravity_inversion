**Robust Evaluation of Geometric Parameterizations in Archaeological Gravity Inversion**



MATLAB implementation accompanying the manuscript: *Robust Evaluation of Geometric Parameterizations in Archaeological Gravity Inversion: The Trnava Case Study*, developed by the **GPINV Research Group, University of Oviedo**.





\# Overview



This repository contains the complete MATLAB implementation used to perform the numerical experiments described in the accompanying manuscript.



The software implements a stochastic three-dimensional gravity inversion framework based on the **Real-Representation Particle Swarm Optimization (RR-GPSO)** algorithm using reduced-dimensional rectangular prism parameterizations.



The repository includes:



\- 3D gravity inversion software;

\- forward gravity modeling routines;

\- RR-GPSO implementation;

\- convergence analysis;

\- statistical comparison of different geometric parameterizations;

\- archaeological interpretation utilities.



The objective is to evaluate how different reduced-dimensional geometric parameterizations influence inversion performance, robustness, convergence behaviour, geometric characterization, and computational cost through repeated stochastic inversion runs.





\# Repository Structure



MAIN\_PSO\_CRYPTS.m                  Main inversion program



pso\_grav3D.m                       RR-GPSO optimization algorithm



PSO\_options.m                      Optimization parameters



initialpop.m                       Initial swarm generation



fcost\_prisma\_rectangular\_cripta.m  Objective function



GravPrismaRectangular.m            Forward gravity model



GravNubePuntos.m                   Point-cloud gravity routine



DiscretizaPrismaRectangular.m      Prism discretization



PrismasSolapanSAT.m                Overlap detection between prisms



Results\_analysis.m                 Statistical analysis



convergence.m                      Convergence analysis



ArchaeologicalInterpretationP4.m   Archaeological interpretation



ComputeBodyGeometry.m



ComputeGeometryStatistics.m



CreateGeometryTable.m



ExportGeometryTables.m



ExportGeometryLatex.m



posterior.m                        Posterior model selection



readSRF\_ASCIIgrid.m                Surfer ASCII grid reader





\# Software Requirements



\- MATLAB R2022a or newer.

\- Statistics and Machine Learning Toolbox.



No additional third-party libraries are required.





## Dataset Attribution

The microgravity grid used in this project (`02_Trnava_micrograv.grd`) was provided by **Prof. Roman Pašteka** (Comenius University in Bratislava, Slovakia). 

* **Format:** Surfer ASCII Grid (DSAA).
* **Usage Rights:** Provided for academic and research reproducibility purposes associated with this repository. If you use this dataset in your research, please acknowledge the original source.




\# Running the Code



\## Gravity inversion



Execute matlab

MAIN\_PSO\_CRYPTS





The program performs the RR-GPSO inversion and stores the inversion results.





\## Statistical analysis



After completing the independent inversion runs, execute Matlab *Results\_analysis* 

to compute the descriptive statistics and generate the figures reported in the manuscript.





\## Convergence analysis



Execute Matlab *convergence* to analyse the convergence behaviour of the different geometric parameterizations.





\# Methodology



The inversion framework is based on



\- Real-Representation Particle Swarm Optimization (RR-GPSO);

\- reduced-dimensional rectangular-prism parameterizations;

\- repeated stochastic inversion;

\- ensemble-based statistical analysis;

\- multi-criteria evaluation of inversion performance.





\# Expected Outputs



The inversion software generates



\- recovered models;

\- predicted gravity anomalies;

\- residual gravity fields;

\- convergence histories;

\- execution times;

\- MATLAB result files (.mat).



The analysis scripts generate



\- descriptive statistics;

\- convergence statistics;

\- comparison tables;

\- publication-quality figures.





\# Reproducibility



The repository contains all MATLAB source code required to reproduce the computational methodology presented in the accompanying manuscript.



Because RR-GPSO is a stochastic optimization algorithm, individual inversion runs may produce slightly different solutions. The results reported in the manuscript are based on multiple independent realizations and should therefore be interpreted statistically rather than from a single inversion.





\# Citation



If you use this software in academic work, please cite the accompanying publication:



**Robust Evaluation of Geometric Parameterizations in Archaeological Gravity Inversion: The Trnava Case Study**





\# Authors



GPINV Research Group



Department of Mathematics



University of Oviedo



Oviedo, Spain





\# License



This software is distributed under the MIT License.



Copyright (c) 2026 GPINV Research Group, University of Oviedo.



Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, subject to inclusion of the above copyright notice and this permission notice.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

