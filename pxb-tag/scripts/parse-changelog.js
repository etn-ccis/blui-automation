const fs = require('fs');

const VERSION = process.argv.slice(2);

fs.readFile('../CHANGELOG.md', 'utf8', (err, data) => {
    const separator = '## v';
    const releases = data.split(separator);
    for (const release of releases) {
        if (release.includes(VERSION)) {
            console.log(`${separator}${release}`);
        }
    }
});