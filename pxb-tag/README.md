# @pxblue/tag

This Command Line tool is a utility for automatically creating tags and github releases through a continuous integration pipeline. 
Given a `package.json` and a `CHANGELOG.md`, it will parse out the latest release notes, install the Github CLI and publish the latest release. 

## Prerequisites

In order to use this utility you must have the following installed:

-   [NodeJS](https://nodejs.org/en/download/) 12+
-   npm


## Usage

This package is intended to run only within a Linux image.

Add the following to your package.json scripts section: 

```
"scripts": {
    "pxb-tag": "pxb-tag"
}
```

```
cd [root]
yarn add @pxblue/tag && yarn pxb-tag -b <branch-name> -s <tag-suffix>
```

> The `root` directory assumes a `package.json` and a `CHANGELOG.md` are available.

#### Available options

The following table list out some options for the `pxb-tag` command. All these options can be configured:

| Option | Description                           |
| ------ | ------------------------------------- |
| `-b`   | (default: dev) The branch you are on. |
| `-s`   | (default: '') The tag suffix.         |

> The branch flag is used to determine whether a latest package can be published. Latest packages may only be published for the master branch (-b master).
