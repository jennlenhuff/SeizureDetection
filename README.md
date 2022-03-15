# SeizureDetection
SeizureDetection Software

ADD Lab Seizure Detection

Contributors: Thomas Newell, John Wagner, Kyle Thomson


Summary:
This is a seizure detection algorithm designed for use in the ADD lab for designated animal models. 
There are four algorithms that process an EEG signal and a main algorithm that combines the other algorithmic results, applies a threshold, and identifies potential seizures to be reviewed manually.
To manually run the seizure detection, first edit the paths.txt under Variables\ to ensure the correct analysis paths are chosen. Then, change the environment path to the seizure detection tree.
Open the MasterScript and run it, or run the run.bat file, or schedule a task using Windows Task Scheduler to repeatedly call the analysis at a fixed interval [expand on this perhaps with pictures].
Once the analysis is complete, the thresholding result can be reviewed via the *.png's created for each channel in each analyzed folder. 
The detection files may then be loaded into the Seizure Playback software for fast review.

The analysis utilizes MATLAB's parallel computing toolbox, if you'd like to disable this feature, change the 'parfor' in MasterScript to 'for'.

- organization and description of functions and outputs here
The primary outputs from the seizure detection is a text file saved with extension *.det. 
Detection files have two columns: first column corresponds to channel, second is time of the detection

Secondary output is a plot of each channel, each plot having the post-processed EEG signal with a line indicating the threshold for detections

Algorithms:
All 4 algorithms use a windowing feature that divides the input data into 12.5 second windows, based on a sampling rate of 500 Hz.
-Autocorrelation: difference between local maxima and minima
-FFT: fourier transform of each 12.5 second window, filtered with WeightFunc (amplifies low frequency band ~9 Hz, attenuates high frequencies and notches at 60 Hz harmonics)
-line length: "coast line" analysis, length of signal in each 12.5 second window
-spike counting/sorting: counts spikes in windows based on a threshold
-Combined algorithm: see manuscript for application of the combined algorithm and the equation used for the combination of previous four algorithms. Parameters for this function stored in Parameters.mat

Variables:
paths to directory trees or computers on network
spike counting function and filter for fourier transform algorithm
Parameters.mat: contains parameters for combined algorithm

- Parameters.mat contains exponential and constant scaling factors for each of the four algorithms, and a threshold for the combined algorithmic result.
These parameters may be freely altered within the Test environment. Any changes made to the parameters for Production should be rigorously tested for accuracy. 
Scripts and functions for testing seizure detection accuracy can be found in the Unit Tests folder.

- paths.txt is a text document containing all paths used in analysis. The MasterScript loads in paths as a cell array and iterates through the paths.

- SpikeFunc and WeightFunc are filters used in spike counting and fourier analysis algorithms respectively.

- envpath is the path to the environment containing analysis functions and scripts
