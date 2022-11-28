# How to track foraging videos using trex
## Terminology
**-d** = directory  
**-i** =  input (name file)  
**-o** = output (how the new file is gonna be named)  
**-s** = settings

## Keyboard shortcuts (from trex GUI)
__S__: Save tracking data  
__D__: Find the blobs in the videos  
__Z__: save _video_.results  
__Space__: Start/stop playback



## Prepare the .settings file
* Open Anaconda terminal
* In the terminal, type ```conda activate tracking```
* Type ```trex``` to open the GUI. You can specify the path where the videos are stored by typing ```-d path/to/video```  
*Note*: Windows uses backslashes!   
```trex d- path\to\video```
* Open one video from the GUI.
* Find the cm_per_pixel: click with the mouse on the edge of the arena, then hold ```Ctrl``` and click on the other edge of the arena. At this point, you will see a botton called ```use known lenght to calibrate```, click it and add  **114cm**
* Now trex will give you the new ```cm_per_pixel``` ratio.
* Open Notepad or a text editor to create a new file, this will be your ```.settings``` file
type: 
```
cm_per_pixel = VALUE
enable_live_tracking = true
output_dir = **path\to\save\videos**
framerate = 30
threshold = 15
track_max_individuals = 1
blob_size_ranges = [[0.8,35]]
track_max_speed = 1000
```
* Once you are done, save this file as ```default.settings```
* This ```settings``` file will be used to track all the videos, you can change as many parameters as you need to make the tracking smoother in your videos, just remember to put these in.

## Open a video from the terminal
* Convert a video using TGrabs from the terminal, with defined ```.settings``` and ```output directory```  

example:    ```tgrabs -d /media/ceci/summer/cue/ -i /media/ceci/summer/cue/VIDEO_NAME.mkv -o /media/ceci/summer/cue/VIDEO_NAME.pv -s /media/ceci/summer/cue/SETTINGS.settings -load```
* Once the video is converted to .pv (and you have ```.results``` and ```.settings``` files) you can ask trex to open  with defined ```.settings``` and ```output directory```  

example:  ```trex -d /media/ceci/summer/cue/ -i /media/ceci/summer/cue/VIDEO_NAME.pv -o /media/ceci/summer/cue/VIDEO_NAME.pv -s /media/ceci/summer/cue/SETTINGS.settings -load```  
This will open the GUI, where you can check if the tracking went well. If something goes wrong and the shrew is lost in some parts of the video, press **D** on the keyboard to see all the blobs, then select the one representing the shrew by clicking on the blob and then on "Fish0"
* When the tracking is fixed, click on **Menu**, then on **save tracking data**.    You can achieve the same goal by pressing **S** on the keyboard

## Open multiple videos and track them 
* To track all videos in a loop, all the files have to be in the same folder. Before moving them together, it's important that all the information you need is included in the file name, such as ```nameshrew_trial_season_experiment.extension```  
Example: ```20201010-1_T1S1_spring_foraging.asf```  
*NOTE: there can't be two videos with the same name!*  
* The temporal sequence of trials is: T1S1, T1S2, T2S1, T2S2.  
