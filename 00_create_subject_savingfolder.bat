@echo off

echo We are on %COMPUTERNAME%.

:: query for new subject code, or set a new one

set /p subjectcode=<03_lsl_LabRecorder/subjectcode.txt
set /p "subjectcode=Enter a new subjectcode or press [ENTER] to keep old code [%subjectcode%]: "
echo %subjectcode%

:: save the new code to the subject code file
echo The new subject code is "%subjectcode%"

:: create the path for the saving directory
set subject_data_root_dir=%cd%\999_recorded_data\%subjectcode%
echo Data saving directory is %subject_data_root_dir%

:: create subject data directory
IF EXIST "%subject_data_root_dir%" (
	echo The saving folder already exists!
	pause
) ELSE (
	echo Creating subject recording root directory...
	mkdir %subject_data_root_dir%
	echo Done.
)

echo The new subject recording root directory is "%subject_data_root_dir%"

:: Save the current subject code and recording directory to file
echo %subjectcode%>03_lsl_LabRecorder/subjectcode.txt
echo %subject_data_root_dir%>03_lsl_LabRecorder/subject_root_directory.txt

exit 0