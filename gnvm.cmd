@ECHO OFF

SET gnvm_root=%~dp0

IF "%PROCESSOR_ARCHITECTURE%" == "X86" (
  SET nvm=%gnvm_root%gnvm-bin\32-bit\gnvm.exe
) ELSE (
  SET nvm=%gnvm_root%gnvm-bin\64-bit\gnvm.exe
)

%nvm% %*