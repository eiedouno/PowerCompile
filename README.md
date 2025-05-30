# PowerCompile
PowerCompile is a Folder compiler for Powershell and Batch / CMD scripts that compiles all of the files into a single ps1, which works great with PS2EXE!

## Features:

- Easy to use UI with PS2EXE integration.
- Option to Show / Hide Console for EXE.
- Base64 your psd1 file.

### WARNING:
It is highly recommended to look over your code first before compiling to exe due to errors that could occur with how your code is written.

CLI APPS MUST HAVE **SHOW CONSOLE** CHECKED TO RUN CORRECTLY.


# Windows Defender Flag
**VERSION 1.7.1 AND LATER AREN'T FLAGGED LETS GO!**

I'm not paying for a cert. I'm just not. Download the ps1 file and convert itself to the exe. Hash it. It's the same thing.

Windows Defender flags it because it is built in powershell and generates a "random" exe (which is the one you compiled). If you don't want to mess with it, just get the console version. For some reason, the console version isn't flagged.

##### Support for auto signing will come later. Needs admin access though.
