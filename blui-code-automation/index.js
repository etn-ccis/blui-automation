process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

var axios = require('axios');
let platformUnitTestCount = 0;
let platformManualTestCount = 0;

const calcAutomationPercentage = (unitTests, manualTests) => ((unitTests / (unitTests + manualTests)) * 100).toFixed(2);

axios
    .all([
        axios.get(
            'https://raw.githubusercontent.com/brightlayer-ui/angular-workflows/dev/login-workflow/VALIDATION.md',
        ),
    ])
    .then((data) => {
        data.map((response) => {
            const sections = response.data.split('\n### ');
            const manualStepsSection = sections[1];
            const unitTestsSection = sections[2];

            /** Parse Manual Steps section, count number of steps. */
            const manualStepsLines = manualStepsSection.split('\n');
            let manualStepsCount = 0;
            manualStepsLines.map((step) => {
                const trimmed = step.trim();
                if (trimmed !== '' && trimmed !== 'Manual Steps' && !trimmed.includes('##')) {
                    manualStepsCount++;
                }
            });

            /** Parse Unit Steps section, parse number of unit tests. */
            const unitTestLines = unitTestsSection.split('\n');
            let unitTestsCount = 0;
            unitTestLines.map((line) => {
                const trimmed = line.trim();
                const num = Number(trimmed);
                if (Number.isInteger(num) && num !== 0) {
                    unitTestsCount = num;
                }
            });

            const url = response.config.url;
            const repoName = url.split('brightlayer-ui/')[1].split('/')[0];
            console.log(`\n*******  ${repoName} Automation Percentage  *******`);
            console.log(`Manual Steps: ` + manualStepsCount);
            console.log(`Unit Tests: ` + unitTestsCount);
            console.log(`Percentage: ` + calcAutomationPercentage(unitTestsCount, manualStepsCount));

            platformManualTestCount += manualStepsCount;
            platformUnitTestCount += unitTestsCount;
        });

        console.log('\n\n*******  Platform Total Automation Percentage  *******');
        console.log(`Total Manual Steps: ` + platformManualTestCount);
        console.log(`Total Unit Tests: ` + platformUnitTestCount);
        console.log(
            `Aggregate Test Automation Percentage: ` +
                calcAutomationPercentage(platformUnitTestCount, platformManualTestCount)
        );
    })
    .catch((error) => {
        console.log(error);
    });
