#@ File (label = "Input directory containing video stills", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File Name: ", value = "Video stills", persist=false) originalTitle


originalTitle = generate_stack_and_save(input, originalTitle, output); 
originalName = file_name_remove_extension(originalTitle); 
pre_processing(originalTitle, output, originalName); 
clean_up();



function generate_stack_and_save(input, originalTitle, output){
	File.openSequence(input);
	Stack.getDimensions(width, height, channels, slices, frames);
	run("Properties...", "channels=1 slices=1 frames=slices pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");
	saveAs("Tiff", output + File.separator + originalTitle + ".tif");
	originalTitle = getTitle(); 
	return originalTitle; 
}

function pre_processing(originalTitle, output, originalName){
	selectWindow(originalTitle);
	
	waitForUser("Please use the rectangle tool to crop out the tube only for measurements. " + "\n" + "Cropping will significantly reduce the processig time and file size.");
	
	run("Duplicate...", "duplicate");
	duplicateTitle = getTitle();
	
	//run("Brightness/Contrast...");
	resetMinAndMax();
	run("8-bit");
	run("Invert", "stack");
	run("Z Project...", "projection=[Average Intensity]");
	ZProjectTitle = getTitle();
	
	imageCalculator("Subtract create 32-bit stack", duplicateTitle, ZProjectTitle);
	ResultsTitle = getTitle();
	selectWindow(ResultsTitle);
	run("Subtract Background...", "rolling=15 stack");
	run("Enhance Contrast", "saturated=0.35");
	saveAs("Tiff", output + File.separator + originalName + "-preprocessed.tif");
}

function clean_up(){
	close("*");
}

function file_name_remove_extension(originalTitle){
	dotIndex = lastIndexOf(originalTitle, "." ); 
	file_name_without_extension = substring(originalTitle, 0, dotIndex );
	//print( "Name without extension: " + file_name_without_extension );
	return file_name_without_extension;
}