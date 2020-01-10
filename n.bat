@echo off
if "%1"=="" goto error
nasm -fbin %1.asm -l %1.lst -o %1.img
qemu-system-i386 -fda %1.img
goto end
:error
echo What do you want to Make?
:end