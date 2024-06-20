# state_change_demo

States and how they affect each other

## Contributions

Outlined in this section are the contributions made by each member for the MAD3-Submission-2 activity.

- BASANAL, CZAR JAY 
    - created BASANAL-GET/posts branch 
    - utilized UserController to fetch list of type <User> from the JSON placeholder api
    - created PostSummaryCard widget to contain all posts of a particular user
    - modified RestDemoScreen to display a list of users in an expansion tile
    - embedded the PostSummaryCard widget within the expansion tile to display all posts of a particular user when the expansion tile is expanded
    - modified PostController by adding getPostById (GET/post/id) method 
    - added PostDetailScreen to display the details of a particular post from a user

- ALCOSEBA, NATHAN MATHEW
    - create ALCOSEBA-PUT branch
    - modified PostSummaryCard to enable post editing
    - modified RestDemoScreen to display edit icon
    - modified PostContoller by adding updatePost 
    - created EditsPostDialog class
    - created _EditPostDialogState class
    - modified HttpService by adding PUT 
    - modified overall user interface by google fonts and a modern minimalist design
    - 
- TUBA, MEXL DELVER
    - created TUBA-POST/posts branch
    - utilized UserController to fetch user list from the JSON placeholder API and included user selection in post creation
    - enhanced AddPostDialog to allow selection of a user when creating a new post, including title and content input fields
    - modified PostController by adding makePost method to handle the addition of new posts and associated user data
    - updated RestDemoScreen to incorporate the new post creation functionality with user association
    - improved PostSummaryCard widget to handle post deletion and integrated it into RestDemoScreen
    - implemented the deletePost method in PostController to handle UI-level post deletion



