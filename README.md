
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

Now, if you go to url given in the 'layersbox init'-phase (https://192.168.99.100), you should see a page with large header 'Layers API'. if you go to https://192.168.99.100/achrails , you should see the achrails front page: empty page with green bar on top of the screen,  links to groups, search area and login. 

(To be added: clvitra, https-issues etc.)

Installing for deployment without Layers Box
--------------------------------------------

Achrails is a straightforward typical Rails app that uses Postgres as a database. It only needs some environment variables to configure.

```
# Host
ACHRAILS_SELF_URI = [required] Base host that achrails will be running under
RAILS_RELATIVE_URL_ROOT = [optional] Set this if achrails is not running in the root eg. /achrails

# Social Semantic Server
SSS_URL = [optional] Enable SocialSemanticServer at this endpoint
DISABLE_SSS = [optional] Disable SSS even is SSS_URL is set, use for debugging

# Authentication
LAYERS_API_URI = [optional] Endpoint of the Learning Layers OIDC
ACHRAILS_OIDC_CLIENT_ID ACHRAILS_OIDC_CLIENT_SECRET = [optional] Credentials of Learning Layers OIDC

GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET = [optional] Enable Google OAuth with credentials

# Mailer
SENDGRID_USER SENDGRID_PASS = [optional] Use Sendgrid to send mail with these

# Video host
ACHRAILS_VIDEO_UPLOADER_URL = [optional] Endpoint to upload videos to from the web UI

# Legacy (should not be used in new deployemenets)
ACHRAILS_AUTO_AUTH = [optional] Automatically redirect to this provider when authenticating
SUPPORT_DIRECT_LL_OIDC = [optional] Enable legacy direct OIDC Bearer authentication
```

You should also run `bundle exec rake sessions:purge` every now and then, preferably with `cron` or so.

Installing for development with Vagrant
------------------------------------------
Simply install Vagrant, clone this repository and run

```sh
vagrant up
```
at the root!

### Development environment variables

You can configure additional environment variables for development as key-value pairs in the .env-file.
Just make sure not commit anything secret to GitHub...

### Using Vagrant and the Layers OIDC and Vagrant together during development

Registering a new development application is pretty easy

Step 1. Go to https://api.learning-layers.eu/o/oauth2/ and register a new account

Step 2. Go to https://api.learning-layers.eu/o/oauth2/manage/dev/dynreg/new to register your vagrant
development machine as a new OID client.

Step 3. In the Main subview, Give your client a nice and descriptive name, and add the following redirect URI
```
    http://10.11.12.13:9292/users/auth/learning_layers_oidc/callback
```

Step 4. Set up the correct permissions at the Access subview

```
openid
profile
email
offline_access
```

Step 5. Go to the "Other"-subview, and untick the "Require authentication time"-checkbox

Step 6. Done! Click save, and you should see the Client ID and Client Secret variables in the "Main"-subview

Step 7. Copy-and-paste the client ID and client secret to the .env file at the base of this repository

```
ACHRAILS_OIDC_CLIENT_ID='<id goes here>'
ACHRAILS_OIDC_CLIENT_SECRET='<secret goes here>'
LAYERS_API_URI='https://api.learning-layers.eu'
```

Step 8. Restart Rails with vagrant ssh. Now, you should see the option "Log in with Learning Layers OIDC"
at the top bar under the login-button at http://10.11.12.13:9292 . Great job! Remember not to commit the secret to GitHub!


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
In OS X you need to be in terminal created by 'Docker Quickstart Terminal.app'. On launch it has displayed an ascii ship and an url that can be used to reach your Docker. It is usually https://192.168.99.100 -- you'll need it soon.

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


Webhook integration
------------------------------------------
Within the group, you can define webhook URLs for the following events. Whenever an event is triggered, the URL is POST'ed with a JSON payload.
The currently available events are:

## New video
Triggered whenever a video is shared to the group

Payload:

```json
{
    "video_title": "Example video",
    "event_type": "new_video",
    "user": {
        "email": "example@user.com",
        "name": "Guy Example",
        "preferred_username": "ExampleMan123"
    }
}

```

## Video edit
Triggered whenever a video is edited within a group

Payload:

```json
{
    "video_title": "Example video",
    "event_type": "video_edit",
    "user": {
        "email": "example@user.com",
        "name": "Guy Example",
        "preferred_username": "ExampleMan123"
    }
}

```
## Video view
Triggered whenever a video belonging to a group is watched

Payload:

```json
{
    "video_title": "Example video",
    "event_type": "video_view",
    "user": {
        "email": "example@user.com",
        "name": "Guy Example",
        "preferred_username": "ExampleMan123"
    }
}

```

Rake tasks
----------

```
# Dump all event data
rake events:dump

# Dump mapping from event entity IDs to names
rake events:names

# Delete expired sessions
rake sessions:purge
```

Web player
----------

If you have a 3rd party service that encounters Ach so! videos, they will have a long id as part of the URI, e.g. `"4e0e3dba-82f6-42eb-9a82-fda064ad3f29"`. To view such video in the web player, you will need to know which achrails server the video is stored, and compose an url in the format `$server + "/videos/" + $long_id + "/player"`. With previous example id this would create something like: `http://achdemoserver.org/videos/4e0e3dba-82f6-42eb-9a82-fda064ad3f29/player`. The web player for given video id will be in this address.  

The web player can also be embedded. It adjusts itself to given size:
```html
<iframe src="http://achdemoserver.org/videos/4e0e3dba-82f6-42eb-9a82-fda064ad3f29/player" width="500" height="300" allowfullscreen=""/>
```

The web player can be provided with an anchor t to give a starting time for playing. `.../player#t=2s`would start the video from 2 second point. Time must be provided in seconds and it can include decimals.  

Development setup
-----------------

- Get [Vagrant](https://www.vagrantup.com) on your platform
- Clone this repository and `cd` into it
- Run `vagrant up`

Now you should have a server running at `http://10.11.12.13:9292`.
You can also use `vagrant ssh` to get into the machine.
`rails` is defined as an upstart service. So if you restart the box
use `sudo service rails restart` to start the server as it's started
automatically only in the provisioning phase, which is done only once.

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
