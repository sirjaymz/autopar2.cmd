REM AUTOPAR2.CMD
REM Version 1.86
REM Created by scorpion273
REM
REM This is a script that will check the par/par2 files as they are
REM in your download directory from newsgroups.
REM I always got sick of having to QuickPAR check them,
REM so I wrote this, to assist me in doing so. :) Hope you like it.
REM I used Scheduling Tasks to call this file every 8 to 10 hours.
REM That way I was able to go to work and come back and see what
REM was missing and not lose it.  Another thought,
REM for collectors, is to allow for a specified path for files to 
REM go for "deep storage". This would allow for user to have a directory
REM that can be specified to save files for newsgroups repost if someone
REM request's a particular release later.


REM NOTES: You need to have par2.exe and unrar.exe and strings.com
REM
REM par2.exe    http://parchive.sourceforge.net/#client_par2cmdline
REM unrar.exe   http://www.rarsoft.com/download.htm
REM strings.com ftp://ftp.simtel.net/pub/simtelnet/msdos/batchutl/string25.zip

REM =============================================================
REM =============================================================
REM ============= BEGIN CONFIGURATION SECTION ===================
REM =============================================================
REM =============================================================

REM =============================================================
REM ================ User Change to your Dir.s===================
REM =============================================================
REM User can specify directories from commandline.
REM AutoPar2.cmd %1 %2
REM %1 is the directory user wants to "check" the files in
REM %2 is the directory user will extract contents of RAR files to
REM Example autopar2.cmd d:\NGDownloads c:\DVD2BURN

REM This finds out if user specified checkdir
if not "%1"=="" set checkdir=%1 & goto xtractyn

REM Checkdir is the directory with you NG's Downloads. No "\" at end
REM =============================================================
REM =============================================================
REM If user does NOT specify %1, the path below will be used.
set checkdir=D:\NewsGroup Downloads
REM =============================================================
REM =============================================================
REM check subdirectories from parent directory listed above?
REM check subdirectories routine is NOT implemented yet.
set chksubdirs=1
REM =============================================================

:xtractyn
REM =============================================================
REM =============================================================
REM Does user want to extract files also?
REM =============================================================
REM XTRCRARS=0   This will NOT extract the files from the RAR archive.
REM XTRCRARS=1   This WILL extract the files from the RAR archive.
REM ========================================================
set xtrcrars=1
REM ========================================================
REM Unrarto is directory where you want your files to extract to.
REM This will be used if XTRCRARS equals 1.
:unrarto
if not "%2"=="" set unrarto=%2 & goto setpwd
REM =============================================================
REM =============================================================
set unrarto=D:\2BURN
REM =============================================================
REM =============================================================
REM PWD is Present Working directory. this is where AUTOPAR2.CMD is.
:setpwd
set pwd=%CD%

REM =============================================================
REM =============================================================
REM Does user want to save the PAR's/RAR's after repair and extraction?
REM =============================================================
REM SAVEPARS=0   This will NOT save the PAR files.
REM SAVEPARS=1   This WILL save the PAR files.
REM ========================================================
set savepars=0
REM ========================================================
REM SAVERARS=0   This will NOT save the RAR files.
REM SAVERARS=1   This WILL save the PAR files.
REM ========================================================
set saverars=0



REM ========================================================
REM ========================================================
REM ===========END CONFIGURATION SECTION ===================
REM ========================================================
REM ========================================================










REM ========================================================
REM ========================================================
REM ================== BEGIN SCRIPT ========================
REM ========================================================
REM ========================================================



REM ========================================================
REM ============ Check to see necessary programs ===========
REM ============ are in working directory ==================
REM ========================================================

if not exist "%PWD%"\par2.exe goto progfail
if not exist "%PWD%"\unrar.exe goto progfail
if not exist "%PWD%"\strings.com goto progfail

REM ========================================================
REM ============ Create List of Subdirectories =============
REM ============ Starting at Checkdir directory ============
REM ========================================================
REM Will use this as the top level of directories.
REM subdir routine implemented by just changing the checkdir
REM directory specified by user. then it's just a matter 
REM of looping through the code to run it over and over
REM against all the subdirectories under the top checkdir
REM directory. This saves allot of coding.

REM Create the subdirectory list.
set topdir=%checkdir%
dir /B /AD "%topdir%"> "%PWD%\subdir.lst"
type subdir.lst >> "%PWD%\autopar2.log"
REM now create enviroment variables for all the subdirs.


REM ================   Subdirectories =======================
REM === Create a list of the subdirs and set the environment
REM === variables. subdir1,subdir2, etc,... =================
REM ========================================================
REM prepare to work with subdirectories.
echo set subdline=0 > %PWD%\getdirs.bat
echo :nextdir >> %PWD%\getdirs.bat
echo REM get dir from a list in a text file. (subdir.lst) >> %PWD%\getdirs.bat
echo REM increment the count. >> %PWD%\getdirs.bat
echo strings subdline= ADD %%subdLINE%%,1 >> %PWD%\getdirs.bat
echo strings subdir= READ subdir.lst,%%subdLINE%% >> %PWD%\getdirs.bat
echo echo "%%subdir%%">> %PWD%\getdirs.bat
echo if "%%subdir%%"=="" goto end>> %PWD%\getdirs.bat
echo echo set subdir%%subdLINE%%=%%subdir%%^>^> %%PWD%%\subdir.cmd >> %PWD%\getdirs.bat
echo goto nextdir >> %PWD%\getdirs.bat
echo :end >> %PWD%\getdirs.bat
echo exit >> %PWD%\getdirs.bat
REM call the batch file that created to get subdirs
start /wait %SystemRoot%\system32\command.com /E:4000 /C %PWD%\getdirs.bat
type getdirs.bat >> "%PWD%\autopar2.log"
REM del "%PWD%\getdirs.bat" >nul:

REM ========================================================
REM ============= Set Subdirectories Environment Vars ======
REM ========================================================
call "%PWD%\subdir.cmd"
type subdir.cmd >> "%PWD%\autopar2.log"

REM ========================================================
REM ============= Now Set Subdirectory1 as the first =======
REM ==================== directory to test. ================
REM ========================================================

:subdir
set subdircount=0
:nextsubdir
set /a subdircount=%subdircount%+1
set label=subdir
set d=%label%%subdircount%
set percent=%%
echo set subdir=%percent%%d%%percent%>"%PWD%"\subdirvar.cmd
call "%PWD%\subdirvar.cmd"
rem if exist subdirvar.cmd del subdirvar.cmd
set subdir=%subdir:~0,-1%
set checkdir=%topdir%\%subdir%

:chkrnds
REM ========================================================
REM ============ Check for previous runs and files =========
REM ========================================================
if exist "%checkdir%\waitround9.flg" goto postwaitround9
if exist "%checkdir%\waitround8.flg" goto postwaitround8
if exist "%checkdir%\waitround7.flg" goto postwaitround7
if exist "%checkdir%\waitround6.flg" goto postwaitround6
if exist "%checkdir%\waitround5.flg" goto postwaitround5
if exist "%checkdir%\waitround4.flg" goto postwaitround4
if exist "%checkdir%\waitround3.flg" goto postwaitround3
if exist "%checkdir%\waitround2.flg" goto postwaitround2
if exist "%checkdir%\waitround1.flg" goto postwaitround1
set checkround=0


REM ========================================================
REM ================   Create List files  ==================
REM ========================================================
:makelist
if exist %PWD%\par2file.cmd del /f %PWD%\par2file.cmd > nul:
REM get file list of par2's into a file called par2file.lst
REM get file list of rar's into a file called rarfile.lst
dir /b "%checkdir%\*.par?" > %PWD%\par2file.lst
dir /b "%checkdir%\*.part*01.rar" > %PWD%\rarfile.lst
dir /b "%checkdir%\*.r00" >> %PWD%\rarfile.lst
dir /b "%checkdir%\*.001" >> %PWD%\rarfile.lst



type par2file.lst >> "%PWD%\autopar2.log"
type rarfile.lst >> "%PWD%\autopar2.log"

REM ================   PAR2/PAR  ================================
REM prepare to work with par files.
echo set par2line=0 > %PWD%\getpars.bat
echo :nextfile >> %PWD%\getpars.bat
echo REM get file from a list in a text file. (par2file.lst) >> %PWD%\getpars.bat
echo REM increment the count. >> %PWD%\getpars.bat
echo strings par2line= ADD %%PAR2LINE%%,1 >> %PWD%\getpars.bat
echo strings par2file= READ par2file.lst,%%PAR2LINE%% >> %PWD%\getpars.bat
echo echo "%%par2file%%">> %PWD%\getpars.bat
echo if "%%par2file%%"=="" goto end>> %PWD%\getpars.bat
echo echo set par2file%%PAR2LINE%%=%%par2file%%^>^> %%PWD%%\par2file.cmd >> %PWD%\getpars.bat
echo goto nextfile >> %PWD%\getpars.bat
echo :end >> %PWD%\getpars.bat
echo exit >> %PWD%\getpars.bat
REM call the batch file that created to get par2files
start /wait %SystemRoot%\system32\command.com /E:4000 /C %PWD%\getpars.bat
type getpars.bat >> "%PWD%\autopar2.log"
REM del "%PWD%\getpars.bat" >nul:



REM ================   RAR  ==================================
REM prepare to work with rar files.
REM Get the rars from the directory into a list.
echo set rarline=0 > %PWD%\getrars.bat
echo :nextfile >> %PWD%\getrars.bat
echo REM get file from a list in a text file. (rarfile.lst) >> %PWD%\getrars.bat
echo REM increment the count. >> %PWD%\getrars.bat
echo strings rarline= ADD %%RARLINE%%,1 >> %PWD%\getrars.bat
echo strings rarfile= READ rarfile.lst,%%RARLINE%% >> %PWD%\getrars.bat
echo if "%%rarfile%%"=="" goto end>> %PWD%\getrars.bat
echo echo set rarfile%%RARLINE%%=%%rarfile%%^>^> %%PWD%%\rarfile.cmd >> %PWD%\getrars.bat
echo goto nextfile >> %PWD%\getrars.bat
echo :end >> %PWD%\getrars.bat
echo exit >> %PWD%\getrars.bat
REM call the batch file that created to get rarfiles
start /wait %SystemRoot%\system32\command.com /E:4000 /C %PWD%\getrars.bat
type getrars.bat >> "%PWD%\autopar2.log"
REM del "%PWD%\getpars.bat" >nul:


REM ================   Environment Vars ===============================

REM Now set the file environment variables according to what the batch
REM created in par2file.cmd
call "%PWD%\par2file.cmd"
REM should set all files for par2's to be checked.
type "%PWD%\par2file.cmd" >> "%PWD%\autopar2.log"

REM del "%PWD%\par2file.cmd >nul:


REM Now set the file environment variables according to what the batch
REM just created in rarfile.cmd
call "%PWD%\rarfile.cmd"
type rarfile.cmd >> "%PWD%\autopar2.log"
REM del "%PWD%\rarfile.cmd" >nul:

REM Since there wasn't a waitrndflg file. anything that fails
REM technically would be the first failure, provided its not 
REM already included in a later round. so set the round count
REM to 1
set waitroundcnt=1

REM ================   PAR2/PAR  ================================

REM should set all files names into the environment for par2's to be checked.
REM should set all files names into the environment for rar's to be checked.

REM now verify that the pars/rars are good with par scripts.

:par2
set par2count=0
set par2delcount=0
:par2count
set /a par2count=%par2count%+1
set label=par2file
set z=%label%%par2count%
set percent=%%
echo set par2file=%percent%%z%%percent%>"%PWD%\par2filevar.cmd"
call "%PWD%\par2filevar.cmd"
if "%par2file%"=="" goto checkround
set par2file=%par2file:~0,-1%

REM ================  CHECK PAR2/PAR  ============================

:checkpar
REM Check if the current par2 is the same set as the previous par2.
REM If the current par2 is the same, goto par2count and get another.
set par2current=%par2file%
set par2ext=%par2current:~-4%
if "%par2ext%"==".PAR" goto par2minus4
if "%par2ext%"==".par" goto par2minus4
if "%par2ext%"=="PAR2" goto par2minus5
if "%par2ext%"=="par2" goto par2minus5
goto EOF

:par2minus4
set par2current=%par2current:~0,-4%
set par2firstfile=%par2current%
goto par2minus1

:par2minus5
set par2current=%par2current:~0,-5%
set par2firstfile=%par2current%
goto par2minus1

:par2minus1
set par2ext=%par2current:~-4%
if "%par2ext%"==".vol" goto par2minusdotvol
if "%par2ext%"=="" goto par2verify
set par2current=%par2current:~0,-1%
if "%par2current%"=="" goto par2firstfile
if "%par2current%"=="Copy(1)" goto par2count
goto par2minus1

:par2firstfile
set par2prev=%par2firstfile%
goto par2verify

:par2minusdotvol
set par2current=%par2current:~0,-4%
if "%par2current%"=="" goto par2verify
if "%par2current%"=="%par2prev%" goto par2count

:par2prev
set par2prev=%par2current%

:par2verify
REM check the files here, if good, go and get another par2file.
%PWD%\par2 v "%checkdir%\%par2file%"
if errorlevel 5 goto par2what
if errorlevel 4 goto par2count
if errorlevel 3 goto par2count
if errorlevel 2 goto waitround%waitroundcnt%
if errorlevel 1 goto par2repair
if errorlevel 0 goto par2delcount
goto par2verify

REM errorlevel 5 par2 error i don't know about. figure it out.
REM errorlevel 4 Main packet not found. This is a odd error.
REM errorlevel 3 par2 file does not exist as specified.
REM errorlevel 2 par2 file not able to repair.
REM errorlevel 1 par2 file needs repair and can repair it.
REM errorlevel 0 par2 file is GOOD to GO! no repair needed.


:par2repair
REM repair the parfile
%PWD%\par2 r "%checkdir%\%par2file%"
REM don't do any error checking. have the verify option do it.
goto par2verify


:par2delcount
set /a par2delcount=%par2delcount%+1
set par2delfile%par2delcount%=%par2file%
goto par2count




REM ================   RAR  ==================================
:rarfile
REM RAR files should already be set in environment from above.
REM clear par2count 'er
rem set par2count=
set rarcount=0
set rardelcount=0
:rarcount
set /a rarcount=%rarcount%+1
set label=rarfile
set zy=%label%%rarcount%
set percent=%%
echo set rarfile=%percent%%zy%%percent%>"%PWD%\rarfilevar.cmd"
call "%PWD%\rarfilevar.cmd"
REM if there are no more files, goto rarfindout
if "%rarfile%"=="" goto rarfindout
REM for some reason rarfile ends with a space, so remove it.
set rarfile=%rarfile:~0,-1%
REM echo the rar file
echo The file to be checked is
echo %rarfile%

:unrarverify
REM unrar verify that rar file is good to extract.
REM PAR file may have said good. Unrar say good? Lets find out.
REM What should be done if unrar finds bad image. Don't know.
REM right now, it continues onto next rarfile set, but the PAR's
REM are already set to be deleted. Well if PAR's say that it is good,
REM and UNRAR t says that it is bad, there is nothing the PAR's can do.
REM so go ahead and delete the PAR's. 
REM Need to find out if unrar can repair possible bad RAR archive set.
%PWD%\unrar t -av- "%checkdir%\%rarfile%"
if errorlevel==3 goto rarcount
if errorlevel==2 goto rarcount
if errorlevel==1 goto rarcount
if errorlevel==0 goto unrar
goto rarcount

REM errorlevel 3 = Rar file did not have all archives files included. ex. missing part 9
REM errorlevel 2 = Unexpected end of archive
REM errorlevel 1 = Authenticity failure,
REM errorlevel 0 = no problems, rarfile is checked out. Good to unrar.

:unrar
%PWD%\unrar x -av- -c- -o+ -y "%checkdir%\%rarfile%" "%unrarto%"
if errorlevel==1 goto unrarfail
if errorlevel==0 goto rarfindout

REM if error level is 0, rar extracted successfully, no need
REM to keep rar's around. consuming space. Prepare to delete.
REM however, some collectors may want to save all archives.
REM need to come up with routine to save off files to user
REM specified directory.
REM and if user wants to delete files, then switch needs to be set
REM to tell routine to run to save files, or run to delete files.

:rarfindout
REM this is the routine to find out if the users wants to save 
REM rar files after extraction. 
if "%saverars%"=="0" goto rardelprep
if "%saverars%"=="1" goto saverarsprep
if "%saverars%"=="" echo saverars variable not set at top of script.
goto eof

REM ================   RAR Prepare for Deletion ==============
:rardelprep
REM Lets set the variable so i get all
REM the rars with the rar archive set.

REM rardelfile=%rarfile% sets the rardelfile to the same as the rarfile
REM set %rardelfile:~0,-4% now takes off the last 4 letters of the name.
REM in this case it should be removing .rar from the name of the archive.
REM problem though, what if the name has <MYFILE.PART01.RAR> part01 in
REM the file name. how do I get rid of the PART01. what if partr
set rardelfile=%rarfile%
echo echoing rardelfile
echo %rardelfile%
if "%rardelfile%"=="" goto par2del
set rardelfile=%rardelfile:~0,-4%
REM echoing rardelfile, should not have .rar extention.
echo %rardelfile%

:rardelminusdot
set rardelext=%rardelfile:~-6%
REM echoing rardelfile
echo %rardelfile%
if "%rardelext%"==".part1" goto rardelminusdot1
if "%rardelext%"=="part01" goto rardelminusdot01
if "%rardelext%"=="art001" goto rardelminusdot001
if "%rardelext%"=="rt0001" goto rardelminusdot0001
if "%rardelext%"=="t00001" goto rardelminusdot00001
goto rardelnow

:rardelminusdot1
set rardelfile=%rardelfile:~0,-6%
set rardelext=
goto rardelnow

:rardelminusdot01
set rardelfile=%rardelfile:~0,-7%
set rardelext=
goto rardelnow

:rardelminusdot001
set rardelfile=%rardelfile:~0,-8%
set rardelext=
goto rardelnow

:rardelminusdot0001
set rardelfile=%rardelfile:~0,-9%
set rardelext=
goto rardelnow

:rardelminusdot00001
set rardelfile=%rardelfile:~0,-10%
set rardelext=
goto rardelnow


REM ================   RAR Delete ==============================
:rardelnow
REM Add the asterix on the end to get all of the parts.
set rardelfile=%rardelfile%.*
REM now delete the rar's.
del /f /q "%checkdir%\%rardelfile%"
set rardelfile=
echo going to rarcount
goto rarcount

REM ================   Save RAR's Prep ==========================
:saverarsprep
REM TO BE DEVELOPED
goto rarcount

REM ================   PAR2/PAR Delete ===========================

:par2del
REM Delete the Par files that were found to be complete. 
REM They should be of no more use since they passed with the
REM files that they were to recover if they were needed.
if "%par2delcount%"=="0" goto EOF
set label2=par2delfile
set y=%label2%%par2delcount%
echo set par2delfile=%percent%%y%%percent%> "%PWD%\par2delfile.cmd"
call "%PWD%\par2delfile.cmd"
if "%par2delfile%"=="" goto EOF
set par2delext=%par2delfile:~-4%
if "%par2delext%"==".par" goto par2delextdotpar
if "%par2delext%"=="par2" goto par2delextpar2
goto par2what

:par2delextdotpar
set par2delfile=%par2delfile:~0,-4%
set par2delfile=%par2delfile%.*
goto par2delfiledel

:par2delextpar2
set par2delfile=%par2delfile:~0,-5%
set par2delfile=%par2delfile%.*

:par2delfiledel
del /f /q "%checkdir%\%par2delfile%"
set /a par2delcount=%par2delcount%-1
goto par2del

goto EOF


REM ================   WAITFLAG  ================================
REM Set the flag that will try the files again after failures.
REM These are the routines that will allow more time for downloads to
REM complete if PAR's cannot repair or if RAR's fail the test.
REM each round, files that are not repairable or fail the test,
REM will progressively get further in the round list.
REM if it reaches round9 and it is not able to extract or repair
REM the files that are in round9, they will be deleted.
REM If you wait 9 rounds and you have ran this every 8 hours, that
REM is a total of 72 hours at least. Most ISP newsgroup servers do
REM not hold bin's for more than that amount of time and you will
REM to find another source anyway.

:checkround
if "%checkround%"=="0" goto rarfile
if "%checkround%"=="1" goto waitround2
if "%checkround%"=="2" goto waitround3
if "%checkround%"=="3" goto waitround4
if "%checkround%"=="4" goto waitround5
if "%checkround%"=="5" goto waitround6
if "%checkround%"=="6" goto waitround7
if "%checkround%"=="7" goto waitround8
if "%checkround%"=="8" goto waitround9
if "%checkround%"=="9" goto toolate
goto makelist

REM ====================WAIT ROUND 1 ===========
:waitround1
if exist "%checkdir%\waitround1.flg" goto par2waitrnd1count
set par2waitrnd1count=0
echo.> "%checkdir%\waitround1.flg"
:par2waitrnd1count
set /a par2waitrnd1count=%par2waitrnd1count%+1
set label=par2file
set z=%label%%par2waitrnd1count%
set percent=%%
echo set %z%=%par2file% >>"%checkdir%\par2waitrnd1.cmd"
goto par2count

:postwaitround1
set checkround=0
set waitroundcnt=2
call "%checkdir%\par2waitrnd1.cmd"
if exist "%checkdir%\par2waitrnd1.cmd" del /f /q "%checkdir%\par2waitrnd1.cmd"
if exist "%checkdir%\waitround1.flg"  del /f /q "%checkdir%\waitround1.flg" 
goto par2

REM ====================WAIT ROUND 2 ===========
:waitround2
if exist "%checkdir%\waitround2.flg" goto par2waitrnd2count
set par2waitrnd2count=0
echo.> "%checkdir%\waitround2.flg"
:par2waitrnd2count
set /a par2waitrnd2count=%par2waitrnd2count%+1
set label=par2file
set z=%label%%par2waitrnd2count%
set percent=%%
echo set %z%=%par2file% >>"%checkdir%\par2waitrnd2.cmd"
goto par2count

:postwaitround2
set checkround=1
call "%checkdir%\par2waitrnd2.cmd"
goto par2


REM ====================WAIT ROUND 3 ===========
:waitround3
if exist "%checkdir%\waitround3.flg" goto par2waitrnd3count
set par2waitrnd3count=0
echo.> "%checkdir%\waitround3.flg"
:par2waitrnd3count
set /a par2waitrnd3count=%par2waitrnd3count%+1
set label=par2file
set z=%label%%par2waitrnd3count%
set percent=%%
echo set %z%=%par2file% >>"%checkdir%\par2waitrnd3.cmd"
goto par2count

:postwaitround3
set checkround=2
call "%checkdir%\par2waitrnd3.cmd"
goto par2


REM ====================WAIT ROUND 4 ===========
:waitround4
if exist "%checkdir%\waitround4.flg" goto par2waitrnd4count
set par2waitrnd4count=0
echo.> "%checkdir%\waitround4.flg"
:par2waitrnd4count
set /a par2waitrnd4count=%par2waitrnd4count%+1
set label=par2file
set z=%label%%par2waitrnd4count%
set percent=%%
echo set %z%=%par2file% >>"%checkdir%\par2waitrnd4.cmd"
goto par2count

:postwaitround4
set checkround=3
call "%checkdir%\par2waitrnd4.cmd"
goto par2



REM ====================WAIT ROUND 5 ===========
:waitround5
if exist "%checkdir%\waitround5.flg" goto par2waitrnd5count
set par2waitrnd5count=0
echo.> "%checkdir%\waitround5.flg"
:par2waitrnd5count
set /a par2waitrnd5count=%par2waitrnd5count%+1
set label=par2file
set z=%label%%par2waitrnd5count%
set percent=%%
echo set %z%=%par2file% >>"%checkdir%\par2waitrnd5.cmd"
goto par2count

:postwaitround5
set checkround=4
call "%checkdir%\par2waitrnd5.cmd"
goto par2


REM ====================WAIT ROUND 6 ===========
:waitround6
if exist "%checkdir%\waitround6.flg" goto par2waitrnd6count
set par2waitrnd6count=0
echo.> "%checkdir%\waitround6.flg"
:par2waitrnd6count
set /a par2waitrnd6count=%par2waitrnd6count%+1
set label=par2file
set z=%label%%par2waitrnd6count%
set percent=%%
echo set %z%=%par2file% >>"%checkdir%\par2waitrnd6.cmd"
goto par2count

:postwaitround6
set checkround=5
call "%checkdir%\par2waitrnd6.cmd"
goto par2


REM ====================WAIT ROUND 7 ===========
:waitround7
if exist "%checkdir%\waitround7.flg" goto par2waitrnd7count
set par2waitrnd7count=0
echo.> "%checkdir%\waitround7.flg"
:par2waitrnd7count
set /a par2waitrnd7count=%par2waitrnd7count%+1
set label=par2file
set z=%label%%par2waitrnd7count%
set percent=%%
echo set %z%=%par2file% >>"%checkdir%\par2waitrnd7.cmd"
goto par2count

:postwaitround7
set checkround=6
call "%checkdir%\par2waitrnd7.cmd"
goto par2



REM ====================WAIT ROUND 8 ===========
:waitround8
if exist "%checkdir%\waitround8.flg" goto par2waitrnd8count
set par2waitrnd8count=0
echo.> "%checkdir%\waitround8.flg"
:par2waitrnd8count
set /a par2waitrnd8count=%par2waitrnd8count%+1
set label=par2file
set z=%label%%par2waitrnd8count%
set percent=%%
echo set %z%=%par2file% >>"%checkdir%\par2waitrnd8.cmd"
goto par2count

:postwaitround8
set checkround=7
call "%checkdir%\par2waitrnd8.cmd"
goto par2

REM ====================WAIT ROUND 9 ===========
:waitround9
if exist "%checkdir%\waitround9.flg" goto par2waitrnd9count
set par2waitrnd9count=0
echo.> "%checkdir%\waitround9.flg"
:par2waitrnd9count
set /a par2waitrnd9count=%par2waitrnd9count%+1
set label=par2file
set z=%label%%par2waitrnd9count%
set percent=%%
echo set %z%=%par2file% >>"%checkdir%\par2waitrnd9.cmd"
goto par2count

:postwaitround9
set checkround=8
call "%checkdir%\par2waitrnd9.cmd"
goto par2


:rarerr
:errout
echo An error occured that there is no handling for
echo errorlevel is 
echo %errorlevel%
goto EOF

:par2what
echo An error occured that there is no handling for
echo errorlevel is 
echo %errorlevel%
goto EOF

:unrarfail
echo An error occured during unraring the file that
echo there is no handling for. This should not have happened.
echo The errorlevel is
echo %errorlevel%
goto EOF

:HELP
echo.
echo.
goto EOF




:progfail
cls
echo You need to have par2.exe and unrar.exe and strings.com
echo for autopar2 to work. Please go the follow locations to
echo acquire these necessary files. Thanks. 
echo.
echo par2.exe    http://parchive.sourceforge.net/#client_par2cmdline
echo unrar.exe   http://www.rarsoft.com/download.htm
echo strings.com ftp://ftp.simtel.net/pub/simtelnet/msdos/batchutl/string25.zip
goto EOF


REM =============================================================
REM ================  Things to Do, or thought to do  ====================
REM =============================================================

REM Make it so that after so many trys of a rar or par, that it deletes those, 
REM This is a thought that if you download to many incompletes that you will
REM eventually fill up your download drive.
REM
REM What about subdirectories.. make it so we are recursive..on/off function?
REM 
REM Also. What about files that are d/l'd that are not ones getting looked at.
REM Such that if it was a zip file. too many of these will cause drive clutter
REM and fill up .. what are we going to do about those?
REM ... 1.83 thought....what if I write code to flush everthing that is not
REM a RAR or PAR/PAR2 file. Such as jpg,zip,nzb,* but rar,par/par2? make
REM option to turn on or off? possible? maybe.
REM Make code to write out a HELP file. possibly autopar2.cmd /help outputs
REM a file called autopar2.hlp and opens notepad to be able to read it. EASY!



REM =============================================================
REM ================   History of changes =======================
REM =============================================================
REM 1.0 First cut, added basic par errorlevels, and basic unrar errorlevels 
REM 	Basic idea came up with. Sick of stupid check pars and waiting.
REM 	Wanted it to be done, just burn, other thought to make autoburn.
REM 	Autoburn is a script also that uses my robotic CD burner arm to 
REM 	burn all my downloads to CD.
REM 1.1 Added par check to see if it was the same as the previous file checked.
REM 	previous file checker is a HUGE savings of I/O and time.
REM 	Created Logging output to autopar2.log
REM 1.2 Fixed if par or par2 did not have or was not a vol to goto
REM 	the parprev directory, if it could not fix it, no reason to try
REM 	again until the script started again from the beginning.
REM 	Added %1 and %2, %1=checkdir and %2=unrarto directory.
REM 1.3 Fixed "unrar" errorlevels. Errorlevel 3 was not handled.
REM 1.4 Fixed PARdelete.
REM 1.5 fixed RARdelete routine. and refixed par2delete routine.
REM 	started implementation of rounds 1 through 9.
REM 1.6 Completed Round 2 to 9.
REM 	Complete Round 1 implementationa and copy to 2to9.
REM 1.7 Fixed bug if par2 file was first, .vol would jump to par2verify
REM 	and not to PAR2PREV. caused double loop on first .par2
REM 	Added del <rar file name>.* instead of del <rar file name>.part001.* routine
REM 1.8 Reworked RARdel routine to work correctly.
REM 1.81 Added .01 increments to build versions.
REM 	 Fixed Par2Del routine to jump to loop correctly.
REM 1.82 Added beginnings of check sub directory routines.
REM 1.83 Fixed RARDEL routine to include .part01.rar increment.
REM 1.84 Thinking of method to allow user to save PAR's/RAR's if
REM 	 user wants to archive files for possible repost later. 
REM 	 Updated to par2.exe v0.4 from v0.2 win32.
REM 1.85 Posted to Newsleecher Forum.
REM 1.85 CheckSubDir's not completed. to be included in 1.86.
REM 1.85 Don't know if the Rounds completely work. investigating.
REM 1.86 Added routine to check to make sure necessary programs
REM 	 are in the working directory.
REM 	 Added XTRCRARs routine. enable disable function.
REM	 Reversed the History lines to make the latest on the bottom.
REM	 Reviewed WAITROUND routines. may not work. investigating.
REM 	 Does not work!!!! Damit.
REM	 Fixing Rounds.. check Idea...check to see if par2file is equal
REM	 to any files currently in any other round above the current round.
REM	 




:EOF
@echo AutoPar2.Cmd has completed.
@echo If you did not see anything get verified or extracted,
@echo check your "checkdir" and "unrarto" directories set at 
@echo the top of this script.

