# Favoured
Project 5 for the Udacity iOS Developer Nanodegree.

## How to run the app?
After you've checked out the code from https://github.com/wouterdevos/Favoured you must open the Favoured.xcworkspace file, not the Favoured.xcodeproj file. This is necessary for the project to use the Cocoapod dependencies that have been included with the project. Once the work space has been opened you should be able to the build and run the project as usual.

## Intended User Experience

#### Summary
Favoured is an app that helps people make difficult fashion choices. For example, if someone can't decide which shirt they should wear to a job interview they can use Favoured to create a poll and ask other users to vote which shirt they think looks best. Once users have placed their votes, the poll creator can check what percentage of users voted for each option, allowing them to make a more informed decision.

#### Login and Registration
When the user starts the app for the first time they will be required to log in with an email address and password. If they do not have an account they will first need to register by clicking on the "Register" button on the navigation bar of the login screen. On the registration screen, the user will need to enter a user name, email address and password. The user will also be able to select an optional profile picture. After all the registration details have been completed, the user can register. If the registration is successful, then the user will navigate to the home screen of the app.

#### Home Screen
The home screen of the app displays a list of user polls. A segmented control appears below the navigation bar with two options: "My Polls" and "All Polls". The "My Polls" option will only display the currently signed in user's polls while "All Polls" displays all registered user's polls. A "Logout" button is visible on the left of the navigation bar. If the user clicks on the "Logoout" button, they will navigate back to the login screen. A "+" button is visible on the right of the navigation bar and lets users create new polls. A user can select any poll in the polls list to vote on that poll.

#### Creating a poll
On the poll creation screen, the user needs to provide a question with a 100 character limit and between 2-4 images. The user cannot add more than four images. The user adds new images by tapping on the "Add Photo" button. Each photo selected by the user will be displayed in a collection view on the screen. The user can change or delete any of the selected photos by clicking on one of the items in the collection view. When the user is ready to create the poll they can click on the "Add Poll" button. After the "Add Poll" button is clicked the user will naviagte back to the Home screen and the poll will displayed at the top of the polls list.

#### Voting on a poll
When the user selects a poll from the polls list, they will navigate to the voting screen. The voting screen lets the user horizontally scroll through all the images submitted for that poll. The screen contains the poll question, the thumbnails for all the images, the currently displayed image and a button for casting a vote. When the user scrolls through the images, the thumbnails will be highlited appropriately to indicate which image in the list is being viewed. If the user has selected one of their own polls, the percentage of votes for each option will be displayed inside the thumbnails. Voting will also be disabled in this case. If the user selects a poll they have not voted on, then the voting buttons will be enabled at the bottom of the screen. Once they select one of the options they will navigate back to the home screen. If they view a poll where they have already voted, then they will be able to see the percentage of votes for each option, as well as the option they voted for. They will not be able to vote again as the voting button will be disabled.
