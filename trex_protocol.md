# How to track foraging videos using trex
## Terminology
**-d** = directory  
**-i** =  input (name file)  
**-o** = output (how the new file is gonna be named)  
**-s** = settings

## Open a file from the terminal
* Open Anaconda terminal
* In the terminal, type ```conda activate tracking```
* Convert a video using TGrabs, with defined ```.settings``` and ```output directory```  

example:    ```tgrabs -d /media/ceci/summer/cue/ -i /media/ceci/summer/cue/VIDEO_NAME.mkv -o /media/ceci/summer/cue/VIDEO_NAME.pv -s /media/ceci/summer/cue/SETTINGS.settings -load```
* From the terminal, you can ask trex to open a file with defined ```.settings``` and ```output directory```  

example:  ```trex -d /media/ceci/summer/cue/ -i /media/ceci/summer/cue/VIDEO_NAME.pv -o /media/ceci/summer/cue/VIDEO_NAME.pv -s /media/ceci/summer/cue/SETTINGS.settings -load```

