//Globule Analyzer
//Return the coordinate of each globule
//to be analyzed by globulator.pl

homedir = getDirectory("home");
dircfg = homedir+"path.cfg";
pathfile2 = File.openAsString(dircfg);
files = split(pathfile2, "\n");
dir = files[0];
dir2 = files[2];

list = getFileList(dir);
for (i=0; i<list.length; i++) {
	open (dir+list[i]);
	getStatistics(are, aver, mini, maxi, stdevi);
	if (aver < 150) {
		brightn = aver+2*stdevi;
		if(brightn < 150) {
			brightn = aver+3*stdevi;
			if(brightn < 150) {
				brightn = aver+4*stdevi;
				if (brightn < 150) {
					brightn = 185;
				}
			}
		}
	}

	
	if(aver >= 150) {
		brightn = 254;
	}
	
	if(brightn >=255) {
		brightn = 254;
	}
	run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack redirect=None decimal=3");		
	title = getTitle();
	title2 = substring(title, 0, lengthOf(title)-4);
	min=newArray(3);
	max=newArray(3);
	filter=newArray(3);
	a=getTitle();
	run("HSB Stack");
	run("Convert Stack to Images");
	selectWindow("Hue");
	rename("0");
	selectWindow("Saturation");
	rename("1");
	selectWindow("Brightness");
	rename("2");
	min[0]=0;
	max[0]=255;
	filter[0]="pass";
	min[1]=0;
	max[1]=255;
	filter[1]="pass";
	min[2]=brightn;
	max[2]=255;
	filter[2]="pass";
	for (j=0;j<3;j++) {
		selectWindow(""+j);
		setThreshold(min[j], max[j]);
		run("Convert to Mask");
		if (filter[j]=="stop") run("Invert");
	}
	
	imageCalculator("AND create", "0","1");
	imageCalculator("AND create", "Result of 0","2");
	for (j=0;j<3;j++){
		selectWindow(""+j);
		close();
	}
	selectWindow("Result of 0");
	close();
	selectWindow("Result of Result of 0");
	rename(a);

	run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display clear");
	selectWindow("Results");
	saveAs("text", dir2+title2+".txt");
	selectWindow("Results");
	run("Close");
	selectWindow(list[i]);
	close();
}

run("Quit");