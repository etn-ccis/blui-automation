# @brightlayer-ui/publish

This Command Line tool is a utility for automatically publishing NPM packages based on the version number in the package.json file.

## Prerequisites

In order to use this utility you must have the following installed:

-   [NodeJS](https://nodejs.org/en/download/) 12+
-   npm

## Usage

You can use this package without installing any global or local dependencies by running it with npx (recommended):

```
npx -p @brightlayer-ui/publish blui-publish -b <branch-name>
```

#### Available options

The following table list out some options for the `blui-publish` command. All these options can be configured:

| Option | Description            | Default |
| ------ | ---------------------- | ------- |
| `-b`   | The branch you are on. | dev     |

> The branch flag is used to determine whether a latest package can be published. Latest packages may only be published for the master branch (`-b master`).
