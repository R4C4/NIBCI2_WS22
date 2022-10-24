# NIBI Project notes

## Setup
# Getting the data and setting up the dev environment
The Git repository files are here to enable the interchage of code and as such only contain the parts of the code project that are necessary for changes.

The important bits of code we need to use for our matlab can be found in the the 04_matlab_based_skeleton_bci_model. All other folders will were added to the
.gitignore file as no changes should be necessary there. First clone the repository to your desired working directory. Afterwards head to the  
[teachcenter](https://tc.tugraz.at/main/course/view.php?id=3208) and download the for_students.zip folder, extract all data from the zip folder into the git target
directory, **DO NOT OVERWRITE ANY FILES**. Make sure your git shows no extra changed files.
Add the 99_library_and_toolboxes folder to your PATH if necessary

# Install all Necessary drivers
Go to 00_installers and install all the included packages after downloading the zip from the teachcenter
1. Install the gtec usbamp driver. The dotNet Framework  needs to be installed in the system first https://www.microsoft.com/en-us/download/details.aspx?id=6041
2. Install python. (Python 3.10 is given but im sure 3.9 is also fine)
3. Install the BrainVision LSL Viewer. Also check that the exe is in the PATH on a windows machine as the bat files call it directly

# Starting development environment
Make sure you are in the folder in matlab from which the script is run!
Run and Advance moves the workspace internally to a temporary folder, this will cause issues so its not possible
to do with this implementation

## Capturing simulated data
1. You can start the 02a_start_simulated_eeg.bat file, this will open a matlab instance. Execute it once
2. Open the p01_mainparadigm_twoclass_mi.m file in a separate matlab instance and execute it the block containing
the lab streaming layer items are were executed (lslinfo_marker)
  - add the 99_library_and_toolboxes as well as all its subfolders to the path in matlab
3. Start the labrecorder using the 04_start_labrecorder.bat file, this will open the labrecorder application, there
2 streams should be visible, one for the lslsinfomarker files, and one for the gtec usbamp application if everything
was correctly installed. Check both streams and record your development session. When finished an xdf file is generated
4. Check if the data is valid:
  - [] The timestamps of when the paradigm steps happen are available
  - [] The paradigm step names available
  - [] The streams themselves are available