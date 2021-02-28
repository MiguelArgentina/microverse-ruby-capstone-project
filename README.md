![](https://img.shields.io/badge/Microverse-blueviolet)

# Telegram Bot

<img width="600" alt="Project Screenshot" src="https://github.com/MiguelArgentina/microverse-ruby-capstone-project/blob/feature/feature_1/bot-screenshot.png">


> This is the capstone project for the Ruby module in Microverse 2.0 program

## Built With

- Ruby

## Features

- Get weather forecast given the user's GPS location
- Get weather forecast for any given city within OpenWeather's API (>200.000 cities)
- Search function to retrieve up to 10 cities matching the search criteria. (if more than 20 results are given, user will be asked to narrow the search criteria)
- Echo function to test if the bot is active
- Log file to save user, location required and time

## Getting Started

### Prerequisites

* Telegram application installed in your cellphone or in your computer
* Available internet connection
* Join [Weather Bot](https://t.me/tucu_clima_bot) channel or
* create a new bot sending a message to [@BotFather](https://telegram.me/BotFather) and follow further instructions to create the bot and get the token
* Get an API key from [OpenWeatherMap](https://home.openweathermap.org/) to access their forecasts [Instructions here](https://openweathermap.org/api)
>Note to TSEs: both Telegram and OW API key will be provided in Code Request
* Permission for accessing GPS from within the app
* Follow instructions

### Setup

* For TSEs: please fill in Telegram Token and API key in ```tokens.rb``` class
* Clone the repository
* Get into the repository's root folder
* Run ```bundle install``` to install the needed gems
* Execute the ```./bin/main.rb``` file to start the bot (the tokens needed will be given in private)

### Usage

* Once the bot has been started, you may test it via the Telegram Bot's Channel.

> Available commands

  * ```/start``` to start the bot
  * ```/stop``` to stop the bot
  * ```/echo``` to test if the bot is active
  * ```/weather``` to let the bot know the user will require a forecast
  * ```/mylocation``` to let the bot know the user will require a forecast based on GPS current location

  > (All commands are clickable from within the Telegram app)


## Author


### Miguel Gomez

<img width="100" alt="Miguel Gomez Profile Picture" src="https://avatars.githubusercontent.com/u/50305489?s=400&u=2d451ca03611a85431ac4e851ab7a4fc3425bb7d&v=4">


* GitHub: [@MiguelArgentina](https://github.com/MiguelArgentina)
* twitter - https://twitter.com/Qete_arg

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

Feel free to check the [issues page](https://github.com/MiguelArgentina/microverse-ruby-capstone-project/issues).

## Show your support

Give a ⭐️ if you like this project!

## 📝 License

This project is [MIT](https://github.com/MiguelArgentina/microverse-ruby-capstone-project/blob/main/LICENSE) licensed.
