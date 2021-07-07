# @pxblue/tag

This Command Line tool is a utility for automatically creating tags and github releases through a continuous integration pipeline.

## Prerequisites

In order to use this utility you must have the following installed:

-   [NodeJS](https://nodejs.org/en/download/) 12+
-   npm

## Usage

You can use this package without installing any global or local dependencies by running it with npx (recommended):

```
npx -p @pxblue/tag pxb-tag -b <branch-name> -s <tag-suffix>
```

#### Available options

The following table list out some options for the `pxb-tag` command. All these options can be configured:

| Option | Description                           |
| ------ | ------------------------------------- |
| `-b`   | (default: dev) The branch you are on. |
| `-s`   | (default: '') The tag suffix.         |

> The branch flag is used to determine whether a latest package can be published. Latest packages may only be published for the master branch (-b master).
