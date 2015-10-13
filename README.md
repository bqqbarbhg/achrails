
# Ach so Web UI and backend

- Works as an adapter for the SocialSemanticServer
- Provides a web player for playing and annotating Ach so! videos with common web browsers.
- Stores 'manifest' files, pieces of additional metadata for videos that allows them to have achso-style annotations.  

Web player
----------

If you have a 3rd party service that encounters Ach so! videos, they will have a long id as part of the URI, e.g. `"4e0e3dba-82f6-42eb-9a82-fda064ad3f29"`. To view such video in the web player, you will need to know which achrails server the video is stored, and compose an url in the format `$server + "/videos/" + $long_id + "/player"`. With previous example id this would create something like: `http://achdemoserver.org/videos/4e0e3dba-82f6-42eb-9a82-fda064ad3f29/player`. The web player for given video id will be in this address.  

The web player can also be embedded. It adjusts itself to given size:
```html
<iframe src="http://achdemoserver.org/videos/4e0e3dba-82f6-42eb-9a82-fda064ad3f29/player" width="500" height="300" allowfullscreen=""/>
```

The web player can be provided with an anchor t to give a starting time for playing. `.../player#t=2s`would start the video from 2 second point. Time must be provided in seconds and it can include decimals.  

Authors
-------

Achrails is developed by the Learning Environments research group at the School
of Arts, Design and Architecture of Aalto University, Finland.

#### Development:

- Samuli Raivio (@bqqbarbhg)
- Jukka Purma (@jpurma)

Licence
-------

```
Copyright 2013–2015 Aalto University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
