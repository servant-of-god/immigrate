# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.2.0] - 2015-08-17
### Added
- Full API documentation
- `currentVersion` option
- `packageJsonFile` option
- `migrateIfFresh` option
- `migrationsDirectory` option
- `immigrateJsonFile` option
- `context` option
- Record last version when immigrate.js was executed
- Execute intermediate migration files if package version increases
- Execute setup.js migration file upon first run
- If a migration file returns a function, execute it
- If a migration file, or it's returned function returns a promise, wait for it
- Validate and sort migration file names sequentially after semver format
- Allow passing of a context to a migration file's function
- Allow CoffeeScript files
- Use location of external package.json file as base directory for relative paths in `options`

## [0.1.0] - 2015-08-13
### Added
- Created basic directory structure and package setup
- API draft
