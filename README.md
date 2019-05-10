# laserinduced-marking-and-coloration
This repository contains three versions of a CAM program to convert pixel-based images to machine code explicitly used for lasermarking. The program version use different algorithms to generate laser-induced markings from black&white over grayscales to even colors. All the code annotations are exclusively in German.

The MATLAB scripts and functions are sorted in the folders "Farben", "Graustufen" and "Schwarzweiss" containing the different versions of this program. To run one of these programs in MATLAB start the MATLAB main script marked with the prefix "bitmap_scanner_". Further procedure is carried out in the MATLAB command window. Please be aware that two paths for data allocation have to be adjusted.

The folder "Colormap_Code" contains two programs to create colormaps and the corresponding parametersets. A collection of colormaps and parametersets is located in the folder "Colormap_Data".

Graphical user interfaces were created for the versions "Schwarzweiss" and "Graustufen". To run these programs start the main script with the suffix "_ GUI" in the MATLAB environment.
