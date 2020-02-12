# SideTexter DataMaster Changelog

Unreleased
---------------------
* Updated: Text message's `send_time` column from an Integer to a Timestamp.
* Removed: `is_admin` from `UserEntity` since it is not a field in the table
* Added: Option `:raw` to `Handler#fetch_all` to specify you want the raw hashes returned instead of the entity.


[1.1.0] - 2020-01-23
---------------------
* Added: New logging method `#verbose_log` which only logs a message when the environment variable `VERBOSE` is true.
  * Updated errors around fetch/update/delete methods to use `#verbose_log`.

[1.0.0] - 2020-01-21
---------------------
* Branded project with Side Texter
* Added: `exceptions.rb` to house exceptions for the project.
* Complete overhual of how entities, handlers, and statements work together.
  * Majority of statements are automatically prepared now

[0.5.0] - 2020-01-18
---------------------
* Added: Columns `zipcode`, `locality`, and `region` to `PhoneEntity`.
* Updated: Increased length of `number` column from 10 to 20 charachters on the `PhoneEntity`.
* Updated: `PreparedStatements#prepare_query_statement` to use `all_column_names` instead of `*` when the request did not provide a custom `:columns` parameter. This ensures that `transform` is able to correctly map the data from postgres to an Entity.

[0.4.0] - 2020-01-15
---------------------
* Added: `bin/clean_postgres` to delete all data associated with this project.
* Updated: `bin/init_postgres` to use TTY Prompt to gather admin user info.
* Added: Columns `created_at` and `updated_at` to all entities.
* Added: Locking around the postgres connection to prevent threading problems.
* Added: `TextHandler#fetch_texts_for_user` which fetches all texts for a user.
* Added: `TextHandler#fetch_texts_for_phone` which fetches all texts for a phone.
* Added: `is_admin` field to user_entity in order to indicate if the user has admin permission. Note: is_admin is not a column on a user entity.
* Fixed: reference error `PhoneHandler#fetch_phone`.
* Added: `PermissionEntity`, `PermissionHandler`, `PermissionStatements` for handling user permissions.

[0.3.0] - 2019-12-31
---------------------
* Added: `PhoneEntity`, `PhoneHandler`, `PhoneStatements` for storing phone numbers owned by users.

[0.2.0] - 2019-12-28
---------------------
* Added: The `logger` gem, and updated the code to use a logger.

[0.1.0] - 2019-12-28
---------------------
* Change: Reorganizing how prepared statements are stored/handled.
* Added: `bin/init_postgres` script to create all the tables required for the project.
* Update: Added magic frozen string comment to the top of every file.

[0.0.1] - 2019-12-28
---------------------
* Initial creation of the DataMaster
