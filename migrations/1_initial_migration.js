const GovToken = artifacts.require('./GovToken.sol');
const MeanRangePoll = artifacts.require('./MeanRangePoll.sol');
const MedianRangePoll = artifacts.require('./MedianRangePoll.sol');
const RangePoll = artifacts.require('./RangePoll.sol');
const EventRangePoll = artifacts.require('./EventRangePoll.sol');
const SecureEventRangePoll = artifacts.require('./SecureEventRangePoll.sol');
const Migrations = artifacts.require('./Migrations.sol');
const IncrementPoll = artifacts.require('./IncrementPoll.sol');
const SecureMedianRangePoll = artifacts.require('./SecureMedianRangePoll.sol');
const SecureMeanRangePoll = artifacts.require('./SecureMeanRangePoll.sol');
const ClusteredMeanRangePoll = artifacts.require('./ClusteredMeanRangePoll.sol');

module.exports = function (deployer) {
    deployer.deploy(GovToken(10000000));
    deployer.deploy(SecureEventRangePoll);
    deployer.deploy(Migrations);
    deployer.deploy(EventRangePoll);
    deployer.deploy(RangePoll);
    deployer.deploy(MedianRangePoll);
    deployer.deploy(MeanRangePoll);
    deployer.deploy(IncrementPoll);
    deployer.deploy(SecureMedianRangePoll);
    deployer.deploy(SecureMeanRangePoll);
    deployer.deploy(ClusteredMeanRangePoll);
};
