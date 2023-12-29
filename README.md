# My custom utilities script
```bash
~$ utils -help
Description: My custom utilities
Usage: utils.sh OPTION [PARAMS]

-h -help
       Print this help message
-r -restart-plasma
       Restart KDE Plasma desktop
-m -set-monitors
       Set the monitors to my default configuration
-s -switch-primary
       Switch the primary monitor
-w -wait-internet [verbose]
       Notify me on internet status [print 'no internet']
-p -pid-command <pid(s)> <command>
       Run a command after a process exits
-d -davinci-convert <file> [audio|video]
       Extract audio to MP3 OR convert Resolve output to MP4 [specify output]
-u -update-system [mirror]
       yay -Syyu & bypass 'sudo session' timeout [update mirror list]
-y -yay
       Bypass 'sudo session' timeout for yay - takes its args
-n -update-notes
       Backup my notes to GitHub
-e -repair-ep [mac address]
       Unpair and repair bluetooth device
-em -ep-mode [card name]
       Switch audio profiles of bluetooth earphones
-mirrors
       Update pacman mirror list
-sudo-timout <program>
       Bypass 'sudo session' timeout on specific program
-start-qemu-vm <vm name>
       Start a QEMU virtual machine
-update-walc <version> <commit msg>
       Update the 'WALC' AUR package
-update-setcustomres <version> <commit msg>
       Update the 'setcustomres' AUR package
-update-salawat <version> <commit msg>
       Update the 'salawat' AUR package
```
# To-Do:

- [ ] Enable running more than one flag at a time
- [ ] Enable updating error statement on the same line in `internet_wait` function
- [ ] Change wait-internet function to operate in the following form when the internet is unreachable:
     - Check if internet is reachable
     - If it isn't, send a notification saying "internet is unreachable; waiting to come back online"
     - Wait for internet connection
- [x] ~~Change `sudo_timeout` function to prompt for `sudo` password first using a `sudo test` command, then proceed with the background loop.~~