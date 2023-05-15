The aim of the analysis is to track flies climbing the walls on the inside of a transparent tube and measure their speed. A video is recorded with a mobile phone and the analysis is performed in Fiji. The workflow contains three parts: 
1. Video conversion from .mov to a sequence of tiff files. 
2. Pre-processing of the video. 
3. Tracking of the flies using Trackmate. 


# Software used
**1. FFMPEG**

FFMPEG is a universal media converter that can read a variety of inputs, filter and transcode them into various output formats.

**2. Fiji **

Fiji is a ‘batteries included’ version of the image processing software ImageJ. It comes bundled with plugins suited to imaging and microscopy. Get it from http://fiji.sc , unzip the archive and run the main executable (ImageJ-win64.exe). 

**3. Fiji Macros**

Download the relevant macros from the public Github repository: https://github.com/Marien-kaefer/Flies-climbing-inside-tube 


# Video conversion to Tiff sequence
Convert movies from mov to tiff sequence via https://mconverter.eu/convert/mov/tiff/ 
Drag and drop .mov file for conversion. Select .tiff. Download as .zip and extract into a folder or download individual files (much slower). This option will only work for videos that are <100 MB. 

For videos larger than 100MB, use FFMPEG: FFMPEG Installation (please note that you will require admin rights on your PC to change environment variables): https://www.youtube.com/watch?v=OspDzkCKFKE&t=189s 
Once FFMPEG has been installed and verified as described in the youtube video above, use the command line prompt to navigate to the folder containing the images. See here for an post of the command line prompts required to navigate the PC drive and folder structure. 

Overview over an FFMPEG command: ffmpeg [options] [[infile options] -i infile]… {[outfile options] outfile}…

Once in the folder that contains the video(s) type the following command (for more info see here): 
ffmpeg -i IMG_3685.mov -pix_fmt rgba IMG_3685_stills_%04d.tif


* "IMG_3685.mov" - input file name
* "-pix_fmt rgba" - set pixel format to rgba 
* "IMG_3685_stills_%04d.tif" - output file name and type (tif), the “%04d” specifies the position of the characters representing a sequential number in each file name matched by the pattern. Using the above example the output files will be called IMG_3685_stills_0001.png, IMG_3685_stills _0002.png, IMG_3685_stills _0002.png and so on. For longer videos you will need to use a higher number (%08d.tif). 

The output files will be written into the same directory as the input files unless a different directory is specified in the command above. Press enter to start the conversion. There wil be various parameters of the video displayed and the last line gives an update on the exported frames. Once the conversion has finished, the command line is ready to receive the next command, e.g. to convert the next video. When done, close the command line prompt. 



# Pre-processing

Open an image of the stack and use the line too to measure the length (pixels) equating to a 2 cm length in the image, e.g. between two markings separated by 2 cm. Once the line has been drawn, type [m] to measure the length. The measurement is displayed in a Results window. Draw several more lines in different areas of the image and measure those and then calculate the average of those measurements. This should be repeated for each video as the distance of the tubes from the video recording device impacts the calibration. 

<p style="text-align:center;"><img src="https://github.com/Marien-kaefer/Flies-climbing-inside-tube/blob/main/readme_images/flies-spatial-calibration.jpg?"  width="60%" ></p>

Ensure to use a PC with sufficient memory to load the image sequences. Check total size of the tiff sequence via file explorer properties to estimate the amount of RAM required. 

The macro preprocessing_for_tracking.ijm has been written that performs the following steps automatically: 
-	User dialog requesting the following:
	1.	<img src="https://github.com/Marien-kaefer/Flies-climbing-inside-tube/blob/main/readme_images/dialogbox.PNG?"  width="80%" ></p>
	2.	Input directory – folder that contains the video stills, only save one video in a folder
	3.	Output directory – where to save the output files to. The output files are all video stills put together in a calibrated tif stack and the pre-processed stack ready for tracking
	4.	File name for the video/pre-processed stack, can be experiment name. Ideally without spaces, or special characters. It is best practice to use letters, numbers dashes, and underscores only. 
	5.	Video frame rate - typically 30 or 60 fps but do check with the phone manufacturer. 
	6.	The number of pixels that equates to a length of 2 cm. In the original video there are markings on the tube. Measure multiple, different 2 cm distances using the line tool and average the numbers as described above. Add the average value in the relevant dialog entry box. 

-	The macro opens image sequence as stack. Depending on the number of images in the sequence this process might take some time. There is a progress bar visible in the Fiji  main window.
-	Swap z and t so that the stack is recognised as a time series rather than a z-stack. 
-	Apply calibrations in xy and time based on the values provided in the dialog box - number of pixels equating to a distance of 2 cm, video frame rate. 
-	There will be another dialog popup window containing the following message: “Please browse the time series and make a note of the start and end frame to be considered for analysis. You will be asked to put in the numbers in the next Dialog.” It is recommended to identify the frame where the tubes have been tapped onto the workbench and are now stationary. Make a note of the beginning and end frames to be used for analysis. 
-	The following dialog box now requests entry of the start and end frame to be considered for analysis. By default, this is set to the whole time series so please adapt accordingly. This dialog does not allow browsing of the time series compared to the previous dialog box which is why this is a two-step process.  
-	The calibrated tif stack will be saved in the specified output folder. 
-	Pre-processing steps:
	-	Crop.
		*	A dialog window will pop up requesting to draw a rectangle around the are of interest, e.g. the tube containing the flies. Cropping out surplus pixels vastly decreases processing time. Once the rectangle has been drawn, click [OK]. 
	-	Convert to 8 bit.
	-	Invert grey values. 
	-	Generate average intensity image and then subtract this from each time point. This will remove static background in the image (e.g. writing, tube, etc.).
	-	Subtract Background to only keep objects that are ~ the size of the flies. Use rolling ball approach with a radius of 15. 
	-	Save pre-processed stack.
-	Option to repeat processing, e.g. for another tube where multiple tubes are in the video. As long as “Yes” is selected, the above point is repeated. Multiple files will be saved as “outputName_n” with n increasing sequentially. Once all crops have been generated select “No”. 
-	The macro automatically closes all image files. The exports can be found in the specified output folder. 

Some optimisation might be required. 

To use the macro, open the .ijm file in Fiji, e.g. by dragging and dropping onto the Fiji main window. The script editor will open. Then click run at the bottom left of the script editor, provide the requested directories and parameters and click [OK]. When prompted, provide parameters or draw a rectangular region of interest around the tube/part of the tube and click OK. The macro will finish with an audible beep. 

<p style="text-align:center;"><img src="https://github.com/Marien-kaefer/Flies-climbing-inside-tube/blob/main/readme_images/raw-pre-processing-comparison.jpg?"  width="60%" ></p>

# Tracking with TrackMate

Now that the data has been pre-processed the flies can be tracked. The TrackMate plugin in Fiji is recommended for this purpose. The parameters listed below are suggestions and must be subject to optimisation . 

Open pre-processed stack in Fiji and then [Pluging > Tracking > TrackMate] 
1.	Check dimension settings, crop if required. 
2.	Select Detector (possible options):
	a.	DOG Detector: identifies round objects, quickest for small spots ~ 5 pixels
		*	Estimated object diameter: 5.5 pixel
		*	Quality Threshold: 3.0
		*	Sub-pixel localisation
		*	This does better than the Voronoi-Otsu-Labelling filter in the first few frames and has ultimately been selected for processing. 
	b.	CLIJ2 Voronoi-Otsu-Labelling (might require installation of CLIJ plugin, https://clij.github.io/clij2-docs/md/voronoi_otsu_labeling/): detects non-circular objects
		*	Spot Sigma: 1 [how close can detected objects be]
		*	Outline Sigma: 0.5 [how precise are segmented objects outlined] 
		*	Use the preview button to empirically assess the object identification at different time points of the video
		*	Please note that there are many mis-identifications in the first few frames
	c.	LOG detector
	d.	**Please note** that no detector will be perfect and you have to find your “good enough”, i.e. the most positive identifications with an acceptable minimal level of false positives and false negatives
3.	The next screen is an information screen, displaying the used parameters and number of spots found (in the whole stack) plus how long it took to identify the given number of spots. 
4.	Initial Thresholding: keep as is, do not threshold – unless there are an unreasonable number of identified spots
5.	Set filters on spots: 
	a.	Assess all frames for erroneous object identifications and filter out as many as possible. 
6.	Overlap Tracker: for shapes that might overlap in consecutive frames
	a.	Min IoU: 0.2
	b.	Scale factor: 1
7.	Filter tracks: 
	a.	Track displacement: > 1.14
8.	Use track scheme to clean up tracks: https://imagej.net/plugins/trackmate/views/trackscheme
9.	Export relevant data, e.g. track length, duration, speed etc. 
