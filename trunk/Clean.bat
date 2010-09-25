@for /r . %%a in (.) do @if exist "%%a\*.~*" del "%%a\*.~*" 
@for /r . %%a in (.) do @if exist "%%a\*.ddp" del "%%a\*.ddp" 
@for /r . %%a in (.) do @if exist "%%a\*.dcu" del "%%a\*.dcu" 
@for /r . %%a in (.) do @if exist "%%a\*.map" del "%%a\*.map" 
@for /r . %%a in (.) do @if exist "%%a\*.rsm" del "%%a\*.rsm" 

