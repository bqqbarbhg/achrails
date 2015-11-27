
# Ach so Web UI and backend

- Works as an adapter for the SocialSemanticServer
- Provides a web player for playing and annotating Ach so! videos with common web browsers.
- Stores 'manifest' files, pieces of additional metadata for videos that allows them to have achso-style annotations.  

Installing for deployment with Layers Box
-----------------------------------------

Achrails is only one part of necessary server backend for Ach so! videos. In addition you'll need authentication service and video storage. Fortunately one part of Learning Layers project is to develop a mechanism for easing installation of this kind of complex modular services for small and medium scale use.  

Achrails can be installed as a service in Layers Box. The instructions for preparing a Layers box can be found here: http://developer.learning-layers.eu/documentation/layers-box/environment-setup/  

You need to be running in an environment where docker-command is available. In OS X this means that you have to launch 'Docker Quickstart Terminal.app'. The terminal launch displays an ascii ship and an uri for your docker server. It is probably https://192.168.99.100 . You'll need that later.  

To create achrails in clean box (in following, 'newbox') run these commands in a folder containing the LayersBox-folder, retrieved from https://github.com/learning-layers/LayersBox :
```
./LayersBox/layersbox init -d newbox
(Give the IP given when docker terminal started, without https://)
cd newbox
../LayersBox/layersbox install learning-layers/openldap
../LayersBox/layersbox install learning-layers/documentation
../LayersBox/layersbox install learning-layers/openidconnect
../LayersBox/layersbox install learning-layers/openldapaccount
../LayersBox/layersbox install learning-layers/achrails
```

Now, if you go to url given in the 'layersbox init'-phase, you should reach 'Layers API'-page. if you go to url/achrails , you should see page from achrails with green bar on top of the screen and links to groups and login. 

To be added: clvitra, https-issues etc. 

Installing for development with Layers Box
------------------------------------------

For development you'll want achrails to be running from your local code instead of relying a prepacked container image. For this we'll assume that you need to have a directory structure something like this:
``` 
github/
    achrails/
    LayersBox/
```
LayersBox is cloned from https://github.com/learning-layers/LayersBox and Achrails from https://github.com/learning-layers/achrails
The folder can be your busy existing github folder, having other subdirectories there has no consequences.

Now create a new Layers box in the github folder.
In OS X you need to be in terminal created by Docker Quickstart Terminal.app. On Launch it has displayed ascii ship and an url that can be used to reach  your docker. It is usually https://192.168.99.100 -- you'll need it soon.

```
cd github
./LayersBox/layersbox init -d newbox
```
In init-command asks for uri for layers box. Give the docker-boat's uri: 192.168.99.100

Now you should have:
``` 
github/
    achrails/
    newbox/
    LayersBox/
```

Then install required components to your newbox. This is similar to deployment build except for the achrails component, here we use special achrails-dev -component. Instead of fetching latest version from github, it links to your 'achrails' folder.

```
cd newbox
../LayersBox/layersbox install learning-layers/openldap
../LayersBox/layersbox install learning-layers/documentation
../LayersBox/layersbox install learning-layers/openidconnect
../LayersBox/layersbox install learning-layers/openldapaccount
../LayersBox/layersbox install jpurma/achrails-dev
```

Installation through layersbox automatically starts the containers, so when the install is finished, after few seconds your layersbox should be able to  respond in https://192.168.99.100 , achrails in https://192.168.99.100/achrails

Now you can go test how changes in achrails affect live server: go to 
../achrails/app/views/home/index.html.erb and append
```
<p>Hello world!</p>
```
to existing page. This should be immediately reflected in https://192.168.99.100/achrails front page.

Since Ruby on Rails is running inside a container, to do proper restart or running rake -commands, you'll have to enter that container. Single commands can be run with:
```
docker run achrails yourcommand
```

(I haven't figured yet how to enter the container outside the running process, will be added when known)

(Also the https -situation is missing, the authentication doesn't work without properly signed https.)

To find out the details of development environment, see https://github.com/jpurma/achrails-dev-Dockerfiles  

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
