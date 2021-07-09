#!/usr/bin/env node

const fs = require('fs');

const VERSION = process.argv.slice(2);

console.log(`Version ${VERSION}`);
console.log();

fs.readFile('CHANGELOG.md', 'utf8', (err, data) => {
    if (err) {
        console.log(err);
        return;
    }

    const separator = '## v';
    const releases = data.split(separator);
    for (const release of releases) {
        if (release.includes(VERSION)) {
            fs.writeFile('TAG_CHANGELOG.md', `## v${release}`, (err) => {
                if (err) {
                    console.log(err);
                    return;
                }
                console.log('Successfully written TAG_CHANGELOG.md');
            });
            return;
        }
    }
    console.log('Error: Could not find version notes in the changelog.');
});
