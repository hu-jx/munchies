# Team Name: Munchies (Team ID: 6646)

## Summary

Munchies is a special food tracker app, designed specifically to help you keep track of your “sweet treat” consumption and spending. 

## Motivation and Aim

Consumption of sweet treats has become more ubiquitous over the years, and this increased sugar consumption has become a health concern and financial strain. However, tracking sweet treats specifically is different from tracking normal meals. Hence, we wish to create a specialised platform where users can keep track of their consumption and aim to reduce consumption of these sweet treats over time. 

The tracker will help users track their snacking habits, as well as function as a social media platform focused on food. The social media aspect helps keep users engaged with the app. By tracking their habits over time, it will allow users to visualise and become more aware of how often they consume sweet treats and how much money they spend on them.

## Built with:

* Figma: UI/UX   
* Flutter  
* Firebase Auth  
* Node.js  
* MongoDB

## Software architecture diagram
<img width="1920" height="1080" alt="software archi diag" src="https://github.com/user-attachments/assets/b48454a6-dd07-44b5-b864-a4fb6673d53a" />

## Usage/Deployment details

Test Account details:

- email address: test@gmail.com  
- password: testing123

How to use the munchies app:

- If no account: register for new account  
  - Required: email address and a password   
- Log in using the test account. Upon successful sign-in, users would be brought to the homepage on a clean state, with a default comment as no records have been made yet. 

## Intended Features

| Feature | Elaboration | Technical Specification |
| :---- | :---- | :---- |
| User authentication (Account Registration) | Users would have to create accounts upon entering the app. The data collected from the account creation would be stored inside MongoDB as a document. | Firebase Authentication functionality to provide authentication services. MongoDB used to store user profile documents. |
| Logging system | Able to add, delete and modify the sweet treats log we have made in the day (optional to add a photo). Individual photo for each log made would be made visible in a specific section where all other logs can be found, ordered by most recent at the top of the page section to the least recent  Frequent snacks can be favourited and quickly added  | Each log would be added into our database in JSON format. Attributes of every log would be the timestamp (date), name of item, cost, and the category the item is part of, as well as an auto-incremental integer ID value.  |
| AI-supported OCR to detect the sweet treat in the photo  | Users would only have to key in the cost of the item and AI would be, reducing the hassle of typing in every log | API integration of Google Vision to determine category which the sweet treat is in, that can be used for other analysis purposes  |
| Calendar \- Monthly, Weekly calendar view | Retrieve and view the expenses and frequency of sweet treat consumption via a calendar and to view the logs made daily | MongoDB querying  |
| Food Habits Dashboard | Able to view charts showing frequency of sweet treats, pie Chart of “sweet treat” distribution and a weekly/monthly Expenditure report on the amount of money spent on the sweet treats   | Create live dashboards with MongoDB querying.   |
| Future You Consumption Dashboard | Forecasting the future expenses and frequency of consumption based on current consumption trends and habits  | Using an API integration to create a classification / regression model on the future expenses and frequency of consumption  → Can be shown in pie chart and line chart forms on a live dashboard    |
| Photo uploads and sharing with friends | A separate page for a feed of photos uploaded by friends on the platform on the mobile app. Photos uploaded as part of a log can be viewed by other users on the platform.  | Photos would be stored in a NoSQL MongoDB database. Graph database for managing connections of friends.  |
| Setting goals for weekly consumption of sweet treats  | Users can set a goal to consume less than a certain amount of sweet treats per week. There will be weekly streaks for staying under the limit  | Fire icons can be added in a corner to show absence or presence of an existing streak on the homepage of our app. Goals, as a separate entity, would be connected to one user and recorded in our database |
| Providing recommended goals for weekly consumption  | Initially hard-coded number for the number of times of consumption, which can later be adjusted based on consumption patterns of the user  | Analysing consumption patterns over time and using predictive analytics to adjust the recommended goal  |
| Recommendations (Pop-up notifications) | There will be automatically triggered pop-ups in the app to encourage users to eat healthier.  These pop ups give users healthier alternatives to their frequently consumed snacks. For example, for an avid milk tea drinker, the app will have pop-ups that encourage them to choose a lower sugar level. | Obtain user data from MongoDB and query for unhealthy consumption patterns and make suitable recommendations |
| AI-generated recommendations  | Based on consumption patterns of the user (e.g. consuming more sweet drinks or consuming more sugary foods like ice cream), AI can help to recommend healthier choices for the user to be include in the pop-up notifications  | Integrating with OpenAI API and then using the APi to provide recommendations of healthier choice snacks  |

## Development plan and timeline (from Milestone 1 onwards) 

Summary: 

- We plan to complete the core features of our project to a minimally functional level, as well as to implement a few extensions of these features, as found below.   
- 

| Actual deadline | Feature to implement | Internal deadline (date to be completed by)  | To be completed by  |
| :---- | :---- | :---- | :---- |
| 29 June Evaluation Milestone 2 | Logging System | 12 June  | Jiaxin |
|  | Calendar view | 14 June  | Jiaxin |
|  | AI-supported OCR for logging  | 12 June  | Jiaxin |
|  | Photo Uploads and sharing functions  | 19 June | Tricia |
|  | Food Habits dashboard (present) | 19 June  | Tricia  |
|  | Future You Consumption | 21 June |  Tricia |
|  | Perform testing | by 27 June | Jiaxin & Tricia |
|  | Documentation  | Ongoing (write up the documentation after finishing every feature) | Jiaxin & Tricia |
|  | Video presentation | by 27 June  | Jiaxin & Tricia |
| 6 July | Peer Evaluation 2 |  |  |
| 27 July Evaluation Milestone 3 | Goal setting | 7 \~ 8 July | Jiaxin |
|  | Analytics for Goal setting to determine customised goal timing | 7 \~ 8 July | Jiaxin |
|  | Recommendations | 7 July | Tricia |
|  | Providing recommendations via OpenAI API   | 7 July |  Tricia |
|  | Perform testing  | 21 July | Jiaxin & Tricia |
|  | Bug fixing  | 24 July | Jiaxin & Tricia  |
|  | Final video presentation  | 26 July | Jiaxin & Tricia |
|  | Poster  | 26 July  | Jiaxin & Tricia |
|  | Documentation  | Ongoing (after finishing every feature) | Jiaxin & Tricia |

## (tentative) Conceptual Data Model
<img width="1920" height="1080" alt="conceptual data model" src="https://github.com/user-attachments/assets/c6c15eca-f912-4b1b-9d46-566ab126571b" />

## Project Log 
Access it here: (https://docs.google.com/spreadsheets/d/11QiNVnTVVibD9JCCDGRvlpyXXOWXNwnVDjcKJHYJDI4/edit?usp=sharing)
