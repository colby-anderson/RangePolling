const { expect } = require('chai');

const MeanRangePoll = artifacts.require('MeanRangePoll');
const GovToken = artifacts.require('GovToken');
contract('MeanRangePoll', function ([_, wallet1, wallet2]) {
    beforeEach(async function () {
        this.MKR = await GovToken.new(500000);
    });

    describe('Basics', async function () {
        beforeEach(async function () {
            this.poll = await MeanRangePoll.new(this.MKR.address);
            await this.MKR.mint(wallet1, 20000);
            await this.MKR.mint(wallet2, 20000);
        });

        it('basic', async function () {
            await this.poll.startPoll(0, 100);
            await this.poll.lock(50, { from: wallet1 });
            await this.poll.lock(80, { from: wallet2 });
            await this.poll.vote(29, 50, { from: wallet1 });
            await this.poll.vote(31, 80, { from: wallet2 });
            const mean = await this.poll.endPoll();
        });
    });
});
