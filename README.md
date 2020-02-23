# Simple PG
Simple PG is a gem for managing interractions with postgresql.

## Environment Setup
The DataMaster needs to connect with Postgresql, as such, the following variables are required:
- `POSTGRESQL_DB_NAME` The name of the database to connect to
- `POSTGRESQL_USERNAME` The user to connect to the database with
- `POSTGRESQL_USER_PASSWORD` The user's password

The DataMaster has optional variables for logging:
- `DEBUG` Whether or not to log to at the debug level. Defaults to `false`.
- `LOG_TO` The name of the file to log to. Defaults to standard out.
- `VERBOSE` Whether or not to log messages logged with the `#verbose_log` method. Defaults to `false`.

## Postgresql Setup
You will need to have Postgresql setup on your computer.
```bash
sudo apt-get install postgresql
```

You will then need to setup your postgres password. To do this, open a postgres console:
```bash
sudo -u postgres psql postgres
```
Then enter the following command to set the password for user `postgres`:
```SQL
\password postgres
```
You can exit the console with `\q`

You will then need to install the ruby support files for running the `pg` gem:
```bash
sudo apt-get install ruby-dev
```

Finally, you can install the `pg` gem:
```bash
sudo apt-get install pg
```

You should now have everything you need to run postgres. You should be able to stop/start/etc the postgres server via:
```bash
sudo service postgresql [COMMAND]
```

Now that we have a working DB, we need to create a user for the project and a database within Postgresql for the project to use. Run the following to create your user:
```bash
sudo -u postgres createuser uma_user
```

You can now login to the postgres console to set the user's password:
```bash
sudo -u postgres psql postgres
```
And now set the password:
```SQL
ALTER USER uma_user WITH password 'password';
```

Finally, we can create the project's database:
```bash
sudo -u postgres createdb uma --owner uma_user
```

### Gotchas
If PG won't install because you are missing the `libpq-fe.h` header, then you can install it with:
```bash
apt-get install libpq-dev
```

## Running the Console
You can connect directly to the database with the DataMaster console script:
```
bundle exec bin/console
```
If you plan to connect through the console, make sure you include a `.env` file located in the root directory of this project.

