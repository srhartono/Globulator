//Contamination Analyzer (Linux)
//Return the coordinate of each crescent and contamination
//to be analyzed by globulator.pl

homedir = getDirectory("home");
dircfg = homedir+"path.cfg";
pathfile2 = File.openAsString(dircfg);
files = split(pathfile2, "\n");
dir = files[1];
dir2 = files[2];

list = getFileList(dir);
for (i=0; i<list.length; i++) {
	open (dir+list[i]);
	run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack redirect=None decimal=3");
	title = getTitle();
	title2 = substring(title, 0, lengthOf(title)-4);
	min=newArray(4);
	max=newArray(4);
	filter=newArray(4);
	a=getTitle();
	run("HSB Stack");
	run("Convert Stack to Images");
	selectWindow("Hue");
	run("Duplicate...", "title=Hue-1");
	selectWindow("Hue");
	rename("0");
	selectWindow("Saturation");
	rename("1");
	selectWindow("Brightness");
	rename("2");
	selectWindow("Hue-1");
	rename("3");

	min[0]=0;
	max[0]=52;
	filter[0]="pass";
	min[1]=0;
	max[1]=255;
	filter[1]="pass";
	min[2]=52;
	max[2]=255;
	filter[2]="pass";
	min[3]=240;
	max[3]=255;
	filter[3]="pass";

	for (j=0;j<4;j++){
		selectWindow(""+j);
		setThreshold(min[j], max[j]);
		run("Convert to Mask");
		if (filter[j]=="stop") run("Invert");
	}
	
	imageCalculator("AND create", "0","1");
	imageCalculator("AND create", "Result of 0","2");
	imageCalculator("OR create", "Result of Result of 0","3");

	for (j=0;j<4;j++){
		selectWindow(""+j);
		close();
	}
	selectWindow("Result of 0");
	close();
	selectWindow("Result of Result of 0");
	close();
	selectWindow("Result of Result of Result of 0");
	rename(a);


	run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display clear");
	saveAs("text", dir2+title2+"CONT.txt");
	selectWindow("Results");
	run("Close");
	selectWindow(list[i]);
	close();
}

run("Quit");
