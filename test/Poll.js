const { expect } = require('chai');
const { BN, expectEvent } = require('@openzeppelin/test-helpers');
const { soliditySha3 } = require("web3-utils");

const MeanRangePoll = artifacts.require('MeanRangePoll');
const GovToken = artifacts.require('GovToken');
contract('MeanRangePoll', function ([_, wallet1, wallet2]) {
    beforeEach(async function () {
        this.MKR = await GovToken.new(500000);
        await this.MKR.mint(wallet1, 20000);
        await this.MKR.mint(wallet2, 20000);
    });

    describe('MeanRangePoll', async function () {
        beforeEach(async function () {
            this.poll = await MeanRangePoll.new(this.MKR.address);
        });

        it('basic', async function () {
            await this.poll.startPoll(0, 100);
            await this.poll.lock(50, { from: wallet1 });
            await this.poll.lock(80, { from: wallet2 });
            await this.poll.vote(29, 50, { from: wallet1 });
            await this.poll.vote(31, 80, { from: wallet2 });
            const mean = await this.poll.endPoll();
            expectEvent(mean, 'PollResult',
                { result: new BN('30') });
        });
    });
});

const MedianRangePoll = artifacts.require('MedianRangePoll');
contract('MedianRangePoll', function ([_, wallet1, wallet2]) {
    beforeEach(async function () {
        this.MKR = await GovToken.new(500000);
        await this.MKR.mint(wallet1, 20000);
        await this.MKR.mint(wallet2, 20000);
    });

    describe('Basics', async function () {
        beforeEach(async function () {
            this.poll = await MedianRangePoll.new(this.MKR.address);
        });

        it('basic', async function () {
            await this.poll.startPoll(0, 100);
            await this.poll.lock(50, { from: wallet1 });
            await this.poll.lock(80, { from: wallet2 });
            await this.poll.vote(29, 50, { from: wallet1 });
            await this.poll.vote(31, 80, { from: wallet2 });
            const mean = await this.poll.endPoll();
            expectEvent(mean, 'PollResult',
                { result: new BN('31') });
        });
    });
});

const IncrementPoll = artifacts.require('IncrementPoll');
contract('IncrementPoll', function ([_, wallet1, wallet2]) {
    beforeEach(async function () {
        this.MKR = await GovToken.new(500000);
        await this.MKR.mint(wallet1, 20000);
        await this.MKR.mint(wallet2, 20000);
    });

    describe('Basics', async function () {
        beforeEach(async function () {
            this.poll = await IncrementPoll.new(this.MKR.address);
        });

        it('basic', async function () {
            await this.poll.startPoll(500, 5);
            await this.poll.lock(10, { from: wallet1 });
            await this.poll.lock(20, { from: wallet2 });
            await this.poll.vote(false, 10, { from: wallet1 });
            await this.poll.vote(true, 20, { from: wallet2 });
            const mean = await this.poll.endPoll();
            expectEvent(mean, 'PollResult',
                { result: new BN('550') });
        });
    });
});

const SecureMeanRangePoll = artifacts.require('SecureMeanRangePoll');
contract('SecureMeanRangePoll', function ([_, wallet1, wallet2]) {
    beforeEach(async function () {
        this.MKR = await GovToken.new(500000);
        await this.MKR.mint(wallet1, 20000);
        await this.MKR.mint(wallet2, 20000);
    });

    describe('Basics', async function () {
        beforeEach(async function () {
            this.poll = await SecureMeanRangePoll.new(this.MKR.address);
        });

        it('basic', async function () {
            await this.poll.startPoll(0, 100);
            await this.poll.lock(50, { from: wallet1 });
            await this.poll.lock(80, { from: wallet2 });
            const bal1 = 29;
            const rand1 = 10;
            const h1 = soliditySha3(bal1 + rand1);
            const bal2 = 31;
            const rand2 = 20;
            const h2 = soliditySha3(bal2 + rand2);
            await this.poll.commit(h1, 50, { from: wallet1 });
            await this.poll.commit(h2, 80, { from: wallet2 });
            await this.poll.reveal(29, 10, { from: wallet1 });
            await this.poll.reveal(31, 20, { from: wallet2 });
            const mean = await this.poll.endPoll();
            expectEvent(mean, 'PollResult',
                { result: new BN('30') });
        });
    });
});

const SecureMedianRangePoll = artifacts.require('SecureMedianRangePoll');
contract('SecureMedianRangePoll', function ([_, wallet1, wallet2]) {
    beforeEach(async function () {
        this.MKR = await GovToken.new(500000);
        await this.MKR.mint(wallet1, 20000);
        await this.MKR.mint(wallet2, 20000);
    });

    describe('Basics', async function () {
        beforeEach(async function () {
            this.poll = await SecureMedianRangePoll.new(this.MKR.address);
        });

        it('basic', async function () {
            await this.poll.startPoll(0, 100);
            await this.poll.lock(50, { from: wallet1 });
            await this.poll.lock(80, { from: wallet2 });
            const bal1 = 29;
            const rand1 = 10;
            const h1 = soliditySha3(bal1 + rand1);
            const bal2 = 31;
            const rand2 = 20;
            const h2 = soliditySha3(bal2 + rand2);
            await this.poll.commit(h1, 50, { from: wallet1 });
            await this.poll.commit(h2, 80, { from: wallet2 });
            await this.poll.reveal(29, 10, { from: wallet1 });
            await this.poll.reveal(31, 20, { from: wallet2 });
            const mean = await this.poll.endPoll();
            expectEvent(mean, 'PollResult',
                { result: new BN('31') });
        });
    });
});

const SecureEventRangePoll = artifacts.require('SecureEventRangePoll');
contract('SecureEventRangePoll', function ([_, wallet1, wallet2]) {
    beforeEach(async function () {
        this.MKR = await GovToken.new(500000);
        await this.MKR.mint(wallet1, 20000);
        await this.MKR.mint(wallet2, 20000);
    });

    describe('Basics', async function () {
        beforeEach(async function () {
            this.poll = await SecureEventRangePoll.new(this.MKR.address);
        });

        it('basic', async function () {
            await this.poll.startPoll(0, 100);
            await this.poll.lock(50, { from: wallet1 });
            await this.poll.lock(80, { from: wallet2 });
            const bal1 = 29;
            const rand1 = 10;
            const h1 = soliditySha3(bal1 + rand1);
            const bal2 = 31;
            const rand2 = 20;
            const h2 = soliditySha3(bal2 + rand2);
            await this.poll.commit(h1, 50, { from: wallet1 });
            await this.poll.commit(h2, 80, { from: wallet2 });
            await this.poll.reveal(29, 10, { from: wallet1 });
            const reveal2 = await this.poll.reveal(31, 20, { from: wallet2 });
            expectEvent(reveal2, 'Reveal',
                { vote: new BN('31'), random: new BN('20') });
        });
    });
});

const EventRangePoll = artifacts.require('EventRangePoll');
contract('EventRangePoll', function ([_, wallet1, wallet2]) {
    beforeEach(async function () {
        this.MKR = await GovToken.new(500000);
        await this.MKR.mint(wallet1, 20000);
        await this.MKR.mint(wallet2, 20000);
    });

    describe('Basics', async function () {
        beforeEach(async function () {
            this.poll = await EventRangePoll.new(this.MKR.address);
        });

        it('basic', async function () {
            await this.poll.startPoll(0, 100);
            await this.poll.lock(50, { from: wallet1 });
            const vote1 = await this.poll.vote(29, 50, { from: wallet1 });
            expectEvent(vote1, 'Vote',
                { ballot: new BN('29'), weight: new BN('50') });
        });
    });
});
