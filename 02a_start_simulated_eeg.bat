set mypath=%cd%
set script_path=%mypath%\04_matlab_based_skeleton_bci_model\00_eeg_simulator\
cd %script_path%

:: start script with simulated eeg
start matlab.exe -r "edit s01_stream_sample_eeg.m; run s01_stream_sample_eeg.m"

cd %mypath%