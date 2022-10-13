set mypath=%cd%
set app_path=%mypath%\99_library_and_toolboxes\

:: Launch the signalviewer app
cd %app_path%
start BrainVisionLSLViewer
cd %mypath%
::echo App launched.

exit 0