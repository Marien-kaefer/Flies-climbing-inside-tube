The aim of the analysis is to track flies climbing the walls on the inside of a transparent tube and measure their speed. A video is recorded with a mobile phone and the analysis is performed in Fiji. The workflow contains three parts: 
1. Video conversion from .mov to a sequence of tiff files. 
2. Pre-processing of the video. 
3. Tracking of the flies using Trackmate. 

# Video conversion to Tiff sequence
Convert movies from mov to tiff sequence via https://mconverter.eu/convert/mov/tiff/ 
Drag and drop .mov file for conversion. Select .tiff. Download as .zip and extract into a folder or download individual files (much slower). 

# Pre-processing
As this would be a repetitive task, a macro has been written that performs the following steps automatically: 
-	User dialog requesting 
	1.	input directory – folder that contains the video stills, only save one video in a folder
	2.	output directory – where to save the output files to. The output files are all video stills put together in a tif stack and the pre-processed stack ready for tracking
	3.	File name for the video/pre-processed stack, can be experiment name. Ideally without spaces, or special characters. Stick to letters, numbers dashes and underscores only. 
-	Open image sequence as stack
-	Swap z and t so that the stack is recognised as a time series rather than a z-stack
-	Save video stills stack
-	Crop 
o	A dialog window will pop up requesting to draw a rectangle around the tube containing the flies. Cropping out surplus pixels vastly increases processing time. Once the rectangle has been drawn, click [OK].
-	Convert to 8 bit
-	Invert grey values 
-	Generate average intensity image and then subtract this from each time point. This will remove static background in the image (e.g. writing, tube, etc.).
-	Subtract Background to only keep objects that are ~ the size of the flies. Use rolling ball approach with a radius of 15. 
-	Save pre-processed stack.
-	Close all image files. You can find the exports in the specified output folder. 
![original image and pre=processed image comparison](https://github.com/Marien-kaefer/Flies-climbing-inside-tube/blob/main/raw-pre-processing-comparison.png?raw=true)

# Tracking with TrackMate

Now that the data has been pre-processed the flies can be tracked. The TrackMate plugin in Fiji is recommended for this purpose. The parameters listed below are suggestions and should be subject to optimisation if required. 

Open pre-processed stack in Fiji and then [Pluging > Tracking > TrackMate] 
1.	Check dimension settings, crop if required. 
2.	Select Detector (possible options):
	a.	CLIJ2 Voronoi-Otsu-Labelling (might require installation of CLIJ plugin, https://clij.github.io/clij2-docs/md/voronoi_otsu_labeling/): detects non-circular objects
		i.	Spot Sigma: 1 [how close can detected objects be]
		ii.	Outline Sigma: 0.5 [how precise are segmented objects outlined] 
		iii.	Use the preview button to empirically assess the object identification at different time points of the video
		iv.	Please note that there are many mis-identifications in the first few frames
	b.	DOG Detector: identifies round objects, quickest for small spots ~ 5 pixels
		i.	Estimated object diameter: 5.5 pixel
		ii.	Quality Threshold: 3.0
		iii.	Sub-pixel localisation
		iv.	This does better than the Voronoi-Otsu-Labelling filter in the first few frames and has ultimately been selected for processing. 
	c.	LOG detector
	d.	Please note that no detector will be perfect and you have to find your “good enough”, i.e. the most positive identifications with an acceptable minimal level of false positives and false negatives
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