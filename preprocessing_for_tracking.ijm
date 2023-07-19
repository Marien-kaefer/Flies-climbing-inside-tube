/*
The aim of the macro is convert a tiff sequence generated from a video recorded with a mobile phone and pre-process it to allow tracking of flies over time in TrackMate. 

The macro provides the second step of the full workflow containing three parts:
1. Video conversion from .mov to a sequence of tiff files.
2. Pre-processing of the video.
3. Tracking of the flies using Trackmate.

INSTRUCTIONS: 
See https://github.com/Marien-kaefer/Flies-climbing-inside-tube#readme

												- Written by Marie Held [mheldb@liverpool.ac.uk] May 2023
												  Liverpool CCI (https://cci.liverpool.ac.uk/)
________________________________________________________________________________________________________________________

BSD 2-Clause License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
*/

#@ File (label = "Input directory containing video stills", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File Name: ", value = "Video-stills", persist=false) originalTitle
#@ Integer (label = "BG Subtraction rolling ball radius (px; > fly 'diameter'): ", value = 15, persist=true) rollingBallRadius
#@ String(label = "Subtract average image? ", choices={"Yes","No"}, style="radioButtonHorizontal") subtractSeriesAverageChoice
#@ Integer (label = "Frame rate: ", value = 60, persist=true) videoFrameRate
#@ Double (label = "Number of pixels equating to 2 cm in length: ",  persist=true) xy_calibration_cm


n = 0; 
originalTitle = generate_stack_and_save(input, output, originalTitle, videoFrameRate, xy_calibration_cm); 
originalName = file_name_remove_extension(originalTitle); 
crop_choice_answer = pre_processing(originalTitle, output, originalName, n);
repeat_process(crop_choice_answer); 
clean_up();
beep(); 


//------------------------- FUNCTIONS -------------------------//
function generate_stack_and_save(input, output, originalTitle, videoFrameRate, xy_calibration_cm){
	interval = 1 / videoFrameRate; 
	xy_calibration = 20 / xy_calibration_cm;
	File.openSequence(input);
	rename(originalTitle); 
	Stack.getDimensions(width, height, channels, slices, frames);
	selectWindow(originalTitle); 
	Stack.setXUnit("mm");
	run("Properties...", "channels=1 slices=" + frames + " frames=" + slices + " pixel_width=" + xy_calibration + " pixel_height=" + xy_calibration + " voxel_depth=1.0000 frame=[" + interval +" sec]");

	waitForUser("Please browse the time series and make a note of the start and end frame to be considered for analysis. " + "\n" + "You will be asked to put in the numbers in the next Dialog.");
	Dialog.create("Start and end frames?");
	Dialog.addMessage("Please enter the start and end frames of the time series that you want to be considered for analysis.");
	Dialog.addNumber("Start frame", 1);
	Dialog.addNumber("End frame", slices);	Dialog.show();
	startFrame = Dialog.getNumber();
	endFrame = Dialog.getNumber();
	run("Make Substack...", "slices=" + startFrame + "-" + endFrame);
	//run("Duplicate...", "duplicate range=" + startFrame + "-" + endFrame);
	image_ID = getImageID();
	selectWindow(originalTitle);
	close();
	selectImage(image_ID);
	rename(originalTitle);

	saveAs("Tiff", output + File.separator + originalTitle + ".tif");
	originalTitle = getTitle(); 
	return originalTitle; 
}

function pre_processing(originalTitle, output, originalName, n){
	selectWindow(originalTitle);
	setTool("rectangle");
	waitForUser("Please use the rectangle tool to crop out the area of interest for measurements. " + "\n" + "Cropping will significantly reduce the processig time and file size.");
	
	run("Duplicate...", "duplicate");
	duplicateTitle = getTitle();
	
	//run("Brightness/Contrast...");
	resetMinAndMax();
	if (bitDepth() != 8) {
		run("8-bit");
	}
	run("Invert", "stack");
	
	if (subtractSeriesAverageChoice == "Yes") {
		run("Z Project...", "projection=[Average Intensity]");
		ZProjectTitle = getTitle();
		
		imageCalculator("Subtract create 32-bit stack", duplicateTitle, ZProjectTitle);
		ResultsTitle = getTitle();
		selectWindow(ZProjectTitle);
		close(); 
		selectWindow(ResultsTitle);
	} 
	else{
		selectWindow(duplicateTitle); 
	}
	run("Subtract Background...", "rolling=" + rollingBallRadius + " stack");
	run("Enhance Contrast", "saturated=0.35");
	saveAs("Tiff", output + File.separator + originalName + "-preprocessed_" + n + ".tif");
	
	//selectWindow(duplicateTitle);
	//close(); 
	selectWindow(originalTitle); 
	close("\\Others");
	//selectWindow(originalName + "-preprocessed_" + n + ".tif");
	//close(); 
	
	crop_option = newArray("Yes", "No");
	Dialog.create("Repeat crop?");
	Dialog.addRadioButtonGroup("Crop another region of interest? ", crop_option, 1, 2, crop_option[0]);
	Dialog.show();
	crop_choice_answer = Dialog.getRadioButton();
	return crop_choice_answer;
}

function repeat_process(crop_choice_answer){
	while (crop_choice_answer == "Yes") {
		n += 1 ; 
		crop_choice_answer = pre_processing(originalTitle, output, originalName, n); 
	}
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

