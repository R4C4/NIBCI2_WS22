set mypath=%cd%
set app_path=%mypath%\03_lsl_LabRecorder\LabRecorder-1.12c\
set labrecorder_cfg_name=labrec_config.cfg

:: Retrieve subject code! Otherwise launch the corresponding script
set /p subjectcode=<03_lsl_LabRecorder/subjectcode.txt
set /p subject_data_root_dir=<03_lsl_LabRecorder/subject_root_directory.txt

del %subject_data_root_dir%\%labrecorder_cfg_name%

:: Setting the configuration for the LabRecorder
set xdf_filename=%subjectcode%-%%b_%%n.xdf

:: Write the configuration file for the LabRecorder
echo StorageLocation=%subject_data_root_dir%\%xdf_filename%>>%subject_data_root_dir%\%labrecorder_cfg_name%
echo RequiredStreams=[]>>%subject_data_root_dir%\%labrecorder_cfg_name%
echo SessionBlocks=[calibration,feedback]>>%subject_data_root_dir%\%labrecorder_cfg_name%
echo ExtraChecks={}>>%subject_data_root_dir%\%labrecorder_cfg_name%
echo EnableScriptedActions = False>>%subject_data_root_dir%\%labrecorder_cfg_name%

:: Change path to the LabRecorder folder, and launch the app
cd %app_path%
start LabRecorder.exe --config %subject_data_root_dir%\%labrecorder_cfg_name%
cd %mypath%
::echo App launched.

exit 0