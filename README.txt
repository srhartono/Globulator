# Globulator 1.1
# by Stella Hartono
# srhartono@ucdavis.edu
# Graduate student in Genetics at UC Davis
# Feel free to email me with any comments/questions!
#
#####################################################

RUNNING
put slide file accordingly in respective folders inside PUT_SLIDES_HERE folder (DIC_ into "DIC" folder, RG_ into "RG" folder)
run perl script start.pl from your terminal (mac/linux) or cmd (windows)

EXAMPLE FILES
Example DIC and RG files can be retrieved from dropbox:
https://www.dropbox.com/sh/mwgupokswkiqi6d/_cwGVzl7Xg/
Put DIC_example.tiff into PUT_SLIDES_HERE/DIC/
Put RG_example.tiff into PUT_SLIDES_HERE/RG/
See README2.html for step-by-step test run - save it as .html and run using internet browser
(https://github.com/srhartono/Globulator/blob/master/README2.html)

IMPORTANT
- make sure each image file have these names: DIC_ and RG_
- make sure each globules in DIC_ image slide have white part on the bottom (see README3.png for more info)
- make sure that your PUT_SLIDES_HERE folder only contain slides that you want to analyze
- Required: install latest Java and latest Perl
- Recommended: install latest R (recommended) and plotrix library
- imageJ program need Graphical User Interface, therefore it can't be run remotely
- imageJ run through Macros that go through tabs, therefore it's advised to not use the computer while it is running

UPDATING IMAGEJ 
1) download imageJ from http://rsbweb.nih.gov/ij/download.html, choose according to your OS
2) download lates ij.jar from http://imagej.nih.gov/ij/upgrade/ij.jar
3) Put the new imageJ FOLDER into GLOBULATOR folder, overwriting old files
4) Put ij.jar into GLOBULATOR folder, overwriting old file

SCRIPTS
0) start.pl
This program automatically run all scripts to process all image files in PUT_SLIDES_HERE folder
Sample Usage: perl globulator/start.pl

1) globulator.pl
This program calculate individual DIC_ and RG_, and RG_CONT files and also automatically run summarizer.pl
Simply drag/drop globulator.pl to your terminal and drag/drop those files.
Sample Usage: perl globulator/bin/globulator.pl -a globulator/result/2011_8_28_13_14/DIC_NNNN.txt -b globulator/result/2011_8_28_13_14/RG_NNNN.txt -c globulator/result/2011_8_28_13_14/RG_NNNCONT.txt
Result is in result folder (e.g globulator/result/2011_8_28_13_14)
GLOB_ contains Globule area, x, y
CRES_ contains Crescent area, x, y
STAT_ contains amount (in percent) of globule area
LINK_ contains globule with linked crescent and their area, x, y
AMB_ contain ambiguous crescent (can't be linked)

2) summarizer.pl
This program make a useful summary of resulting batch result files.
Simply drag/drop summarizer.pl to your terminal and drag/drop folder containing result files
Sample Usage: perl globulator/bin/summarizer.pl globulator/result/2011_9_29_21_28
Result name is "folder name_summary.txt"

3) draw.pl
This program uses R script to draw result of globules/crescent captured by imageJ. 
This is useful to validate result by comparing the original with the result images.
Sample Usage: perl draw.pl globulator/result/2011_9_29_21_28

4) draw_*.R
These are R scripts used by draw.pl to create maps of imageJ results

5) .ijm files
These are macro for imageJ (automatically installed into imageJ)
There are two versions of these: UNIX (mac/linux) and WIN (windows)
GLOB_.ijm analyzes globules
CRES_.ijm analyzes crescent
CONT_.ijm analyzes contamination

