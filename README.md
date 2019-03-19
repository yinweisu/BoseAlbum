# README

### System Design

* Client Side: **Swift**
* Server Side: **Python** deployed on **Heroku**
* Database: **Firebase**
* Storage: **Firebase Storage**
* All the requirement can be done with Client and Firebase alone, but I choose to have a server to access database. Resources(i.e. battery) on cell phone is limited; therefore, I think it is a good practice to keep computation in client side as less as possible.



### Functionality Completed

1. Member management

   * Users can sign up and login with Firebase authentification support.

2. CRD operations on their photos

   * Users can add photos through iOS photo library by clicking the "camera" like button.
   * Users can view their image by simply clicking on the image.
   * Users can delete their image by tapping "Edit" button and tap on the cross shown on each photo.

3. Shareable photo album

   * To open a shared album, simply share the url, and let the viewer open the url in safari.
   * Viewer won't be able to add or delete photos in the album.

4. Background music

   * automatically plays the music.

   * user can pause, play previous, play next.
   * Currently there are only two songs, but should be able to demonstrate the functionality.

   * **Appetize.io simulator seems not supporting music play**. Try to clone the repo and build it to checkout the music play.

5. Git Usage

   * Different branches are used while developing new features.
   * Pull request are used before merging.
     * Not quite neccessary while working alone, but it is a good practice in real life group working

6. Image Encoding/Decoding

   * Images are encoded using **Base64Encoding** before sent to Firebase Storage. The client will then decode the image after downloaded from Firebase Storage.

7. Multiple albums

   * Users can create multiple albums to store their images.

