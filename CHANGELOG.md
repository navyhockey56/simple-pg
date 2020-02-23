# SimplePG Changelog

Unreleased
---------------------
* Updated: `TableHandler#query` to allow passing in the table to run the query on as opposed to always using the table defined within the handler.
* Fixed: Bug in creating a new `JoinTable` within `TableHandler#join`.
* Removed: `Column::Validators#validate_phone_number!` since this is too specific for a generic project.
* Removing unused exceptions.

0.0.1 - 2020-02-14
---------------------
* Basic CRUD on individual tables
* Basic support for simple join queries
* Basic support for many to many relationships
