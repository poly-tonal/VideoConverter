# VideoConverter
## Powershell script converter for any video files (to h264, aac, subrip .mkv files) using ffmpeg For Plex
### ffmpeg and PATH is required (http://ffmpeg.org/)

## File names appended with "_converted" once converted or matching format


### Expected Directory Structure (options in script)
1: All Films/Single Show
```
├── Films
│   ├── Film
│   │   ├── video.mkv
```
2: All TV
```
├── TV
│   ├── TV Show
│   │   ├── Season
│   │   |   ├── Episode.mkv
```

3: Single Season
```
├── Season
│   ├── Episode.mkv
```

Default output formats for video, audio, and subtitles can be changed by changing the variables $videoFormat, $audioFormat, and $subtitleFormat - this uses the format names used by ffmpeg
