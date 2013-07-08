IMPORTANT!
- make sure each image file have these names: DIC_ and RG_
- make sure each globules in DIC_ image slide have white part on the bottom (see readme2.png for more info)
- make sure that your PUT_SLIDES_HERE folder only contain slides that you want to analyze
- put slide file accordingly in respective folders inside PUT_SLIDES_HERE folder (DIC_ into "DIC" folder, RG_ into "RG" folder, while ALL_, R_, and G_ are in "OTHER" folder
- install latest Java
- install latest Perl
- imageJ program need Graphical User Interface, therefore it can't be run remotely
- imageJ run through Macros that goes through tabs, therefore it's advised to not use the computer while it is running

RUNNING:
simply run globulator.pl from your terminal (mac/linux) or cmd (windows)
don't forget to chmod 740 globulator.pl if you're at mac/linux
Windows: perl -f <drag and drop globulator.pl here>
Mac/Linux: <drag and drop globulator.pl here>

to update: 
1) download imageJ from http://rsbweb.nih.gov/ij/download.html, choose according to your OS
2) download lates ij.jar from http://imagej.nih.gov/ij/upgrade/ij.jar
3) Put the new imageJ FOLDER into GLOBULATOR folder, overwriting old files
4) Put ij.jar into GLOBULATOR folder, overwriting old file

Features at bin directory
1) globulator.pl
This program calculate individual DIC_ and RG_, and RG_CONT files and also automatically run summarizer.pl
Simply drag/drop globulator.pl to your terminal and drag/drop those files.
Sample Usage: <.../globulator/bin/globulator.pl> <...globulator/result/2011_8_28_13_14/DIC_NNNN.txt> <...globulator/result/2011_8_28_13_14/RG_NNNN.txt> <...globulator/result/2011_8_28_13_14/RG_NNNCONT.txt>
Result is in result folder (e.g .../globulator/result/2011_8_28_13_14)
GLOB_ contains Globule area, x, y
CRES_ contains Crescent area, x, y
STAT_ contains amount (in percent) of globule area
LINK_ contains globule with linked crescent and their area, x, y
AMB_ contain ambiguous crescent (can't be linked)

2) summarizer.pl
This program make a useful summary of resulting batch result files.
Simply drag/drop summarizer.pl to your terminal and drag/drop folder containing result files
Sample Usage: <.../globulator/bin/summarizer.pl><.../globulator/result/2011_9_29_21_28
Result name is "folder name_summary.txt"

3) .ijm files
These are macro for imageJ (automatically installed into imageJ when you first run globulator_start.pl)
There are two versions of these: UNIX (mac/linux) and WIN (windows)
GLOB_.ijm analyzes globules
CRES_.ijm analyzes crescent
CONT_.ijm analyzes contamination
