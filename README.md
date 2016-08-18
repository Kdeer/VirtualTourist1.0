# VirtualTourist1.0
The fourth Udacity project assignment.

Virtual Tourist allows users to drop pins they want on the map, they'll see the photos other flickr users took at that cooridnates.

When users launch the app, the first view controller they'll see is Map View Controller. In Map View Controller, users can:

1. Drop a pin, after user drop a pin on the map, they'll launch the collection view controller of photos took by other flickr users.
2. Search the location by entering the address or address name
3. clear all the pins users dropped before by press the refresh button.
4. view the address list of all the pins by press the left bottom "list" bottom.
5. view the map in satellite version.

Assume users dropped a pin and now they launched the Collection View Controller of photos, users can:

1. see the pin with address they dropped on the map.
2. see maximally 16 photos took by other flickrs users at that coordiante.
3. delete the photos they don't like on app.
4. switch another set of 16 photos.
5. change the view style to one by one from scatter view.
6. select the photo to launch the image detail view controller. ( the detail view controller just enlarge the size of the photo).

Other features:
1. This app is core data persistent, images are stored by image cache. Every time user switch a photo set, they previous one will be deleted.
2. users can also delete the pins they drop on the map by click the pin's delete button at pin's call out. Or they can go to the address list and delete the address they don't like.



Other features may not listed above, you are welcome to explore by yourself.


