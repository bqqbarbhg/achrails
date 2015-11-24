
# Ach so Web UI and backend

- Works as an adapter for the SocialSemanticServer
- Provides a web player for playing and annotating Ach so! videos with common web browsers.
- Stores 'manifest' files, pieces of additional metadata for videos that allows them to have achso-style annotations.  

Installing with Layers Box
--------------------------

Achrails is only one part of necessary server backend for Ach so! videos. In addition you'll need authentication service and video storage. Fortunately one part of Learning Layers project is to develop a mechanism for easing installation of this kind of complex modular services for small and medium scale use.  

Achrails can be installed as a service in Layers Box. The instructions for preparing a Layers box can be found here: http://developer.learning-layers.eu/documentation/layers-box/environment-setup/  

To create achrails in clean box (in following, 'newbox') run these commands in a folder containing the LayersBox-folder, retrieved from https://github.com/learning-layers/LayersBox :
```
./LayersBox/layersbox init -d newbox
(Now you'll be asked for url that you can use for reaching the newbox)
cd newbox
../LayersBox/layersbox install learning-layers/openldap
../LayersBox/layersbox install learning-layers/documentation
../LayersBox/layersbox install learning-layers/openldapaccount
../LayersBox/layersbox install learning-layers/openidconnect
../LayersBox/layersbox install learning-layers/achrails
```

Now, if you go to url given in the 'layersbox init'-phase, you should reach 'Layers API'-page. if you go to url/achrails , you should see page from achrails with green bar on top of the screen and links to groups and login. 

To be added: clvitra etc. 

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
- Matti Jokitulppo (@melonmanchan)

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
