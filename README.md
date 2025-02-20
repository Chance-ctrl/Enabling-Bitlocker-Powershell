${\textsf{\color{lightblue} Enabling Bitlocker / Checking If Bitlocker is Enabled.}}$
============
A short Powershell script to enable bitlocker, check if it's already enabled, and log the outcome in Windows Event Viewer. I wrote this some years back on a serious IT budget with no way of centralizing logs or capturing log sources. This is a terrible way to tackle this, but this gives an idea of how admins can automate this process in their environment if they lack tools/software.

### What this script does.

* Checks if there is a registered source for bitlocker in Windows Event Viewer.
* Try/Catch to enable Bitlocker on the C:\ Drive.
    * A check is inplace to see whether the C:\ drive is already encrypted or if the encryption process has already started.
    * If the process has already started or fails to start due to a compatiability issue, a log is generated under Windows Logs -> Application, under the source "Bitlocker"
* All outcomes are logged to Windows Event Viewer.


### Misc

* A Group Policy can be created to call this script while the endpoint is booting up, or can be called once the user has logged into the machine.
* It is recommended to handle this type of operation during the imaging process. Note that this will require a Elevated Privileges.




