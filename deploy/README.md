## Install guide

### Prerequisites

1. Docker
2. Docker Compose

### Steps

1. Clone this repository: `git clone https://github.com/Cryptchat/Server.git`.
2. Change directory to the `deploy` directory in this repository: `cd Server/deploy`.
3. Copy the `variables.env.sample` file and rename it to `variables.env`: `cp variables.env.sample variables.env`.
4. Edit the `variables.env` file and fill in the variables. `CRYPTCHAT_HOSTNAME`, `POSTGRES_PASSWORD`, `SECRET_KEY_BASE`, the Firebase-related variables, and either ClickSend or Twilio variables are required.
5. The `POSTGRES_PASSWORD` should be a strong and random password. Generate one with ruby like so: `ruby -e "require 'securerandom'; puts SecureRandom.alphanumeric(64)"`.
6. Repeat the previous step for the `SECRET_KEY_BASE` variable.
7. Run `docker-compose up -d`.
8. Navigate to your hostname in your browser and verify it's working (you'll see `Cryptchat server`) and it's on HTTPS.
9. Register in your server via the application.
10. Grant your user admin via the Rails console: `./deploy/rails-c.sh` and then `User.find_by(country_code: <country_code>, phone_number: <phone_number>).update!(admin: true)`.
