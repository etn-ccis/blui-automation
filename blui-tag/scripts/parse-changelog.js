#!/usr/bin/env node

const fs = require('fs');
const process = require('process');
const VERSION = process.argv.slice(2);

fs.readFile('CHANGELOG.md', 'utf8', (err, data) => {
    if (err) {
        console.error(err);
        process.exit(1);
    }

    const separator = '## v';
    const releases = data.split(separator);
    let found = false;

    for (const release of releases) {
        console.log(release);
        console.log(VERSION);

        // Once the most-recent occurrence of a version is found, skip next steps.
        if (found) {
            continue;
        }

        if (release.includes(VERSION)) {
            found = true;
            fs.writeFile('TAG_CHANGELOG.md', `## v${release}`, (err) => {
                if (err) {
                    console.error(err);
                    process.exit(1);
                }
                console.log('Successfully written TAG_CHANGELOG.md');
                process.exit(0);
            });
        }
    }

    if (!found) {
        console.error(`Error: Could not find version ${VERSION} notes in the changelog.`);
        process.exit(1);
    }
});
