# dargui-docker
Docker container for DarGui intended for usage with UnRaid

dar (http://dar.linux.free.fr/home.html), which stands for Disk ARchive, is a robust and rich featured archiving and backup software.      Cancel changes


It is composed of:
    a library called libdar that exposes both a C++ and a python API,
    a command line program called dar that leverages all the features of libdar.

If you have a need for differential archiving large amounts of files dar is a great tool.
You can create a isolated catalogue of your archived files and do differential backups based on this isolated catalogue,
without the need to have the files still in place on your machine.

dargui (https://dargui.sourceforge.io/) is an userinterface for UI for dar that allows easy usage.

As dargui currently only support dar 2.6.12 I also created a command line only docker for dar 2.7.8
https://github.com/Protarios/dar-docker/


The docker container is available from docker hub at: zerginator/docker-dargui

As the docker is terminal only I currently cannot install it directly from UnRaid Webinterface, as it immidately closes, so run it from the unraid console with an added execution of /bin/bash
