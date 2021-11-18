# Range Polling

### Introduction
#### What is Range Polling?
A range poll is a poll where there are a range of possible outcomes (usually continuous), and voters can somehow vote within this range.
There are many ways to vote in a range poll (e.g. voting to increment a value, choosing any value from the range, commiting then revealing the value, etc) and there are many ways to reach consensus on a result (taking the mean, taking the median, etc). This repository explores implementations of multiple types of range polls implemented in smart contracts. These contracts could be able to be used in a DAO for a defi protocol to vote on system parameters or many other things. 
#### Learn More!
If you would like to learn more about range polling, check out these links:
- https://forum.makerdao.com/t/colbys-research-range-polling-provide-community-feedback-please/11275 (a MakerDAO forum post discussing range polling. This is good to start with.)
- https://docs.google.com/presentation/d/18XEvPU3MCvHfd4etUxNIJY_56iaVKdDkNThSZLtoXJs/edit#slide=id.gf69639c7cd_0_26 (slides of a presentation about range polling)
- https://drive.google.com/file/d/1tFNIwtZcCt-k-HjD9QLoVy12hrrnoc8x/view (a presentation about range polling, somewhat low-level)
- https://docs.google.com/document/d/1e-TiAV1PiixLI785UrcOcf0kv2qSyOuPKvA9Lix9jP8/view (a written document about rnage polling, somewhat low-level)
- https://docs.google.com/document/d/1sbHFWgg0QOLn5wxabuXVDPaUh-3abxQQEJcMmUce0Ps/view (a quick write up of an existing range poll that 1inch uses)
### Structure of Repo
#### Development Set Up
First, clone this repository.
```console
foo@bar:~$ git clone https://github.com/colby-anderson/RangePolling.git
```
Then, make sure node package manager is installed on your machine. If it is not, here are
instructions on how to download it.
https://docs.npmjs.com/downloading-and-installing-node-js-and-npm
Then, in your terminal, navigate to the project directory
```console
foo@bar:~$ cd RangePolling
```
And, install all dependencies with npm
```console
foo@bar:~$ npm i
```
Finally, run the test suite to make sure everything is working
```console
foo@bar:~$ npm run test
```
#### Development Environment
Node package manager is used to keep track of
all javascript dependencies. Hardhat is the testing
framework that is used to test the smart contracts.
The smart contracts are located in the contracts folder.
In most cases, if you would like to develop and test this
repo, you will only need to change the contents of the contracts
and test folders.
### What range polling strategies are implemented?
There are multiple range polling strategies used. Here is a list:
- Clustered Mean Polling
- Event-Driven Polling
- Increment Polling
- Mean Polling
- Median Polling
- Commit/Reveal Median Polling
- Commit/Reveal Mean Polling
- Commit/Reveal Event-Driven Polling

Explanation about the above methods is waved here. The high level details can be understood by reading the "Learn More!" section, and the low level details can be understood by reading the heavily documented code.

However, here are a few notes about architecture. Most of these contracts are very similar, and therefore inherit their similar code from an abstract contract RangePolling. The idea is that these subcontracts will handle vote calculation and result calculation. However, this doesn't work perfectly, so some of the contracts override their parent functions with dummy funciton bodys. And the vote happens in some other way. This is commonly seen with the commit/reveal poll strategies. Furthermore, increment polling is quite distinct from the other strategies, so it doesn't inherit from RangePolling and is an all-in-one sorta contract. It still repeats a lot of code that RangePolling has though. 
### Performance and Deployment
To see how costly each of these polling strategies are (in terms of computation/storage) check out the analysis
in the link below. This link also contains recommendations about deploying these contracts and whether
some can be ran on L1 or L2 or whether they need to be off chain all together.
https://docs.google.com/document/d/1kd7p48bk5-wV2dE00D5SmOEio45iJJ--WdsG7DVJl7w/edit?usp=sharing
To see how much gas each of these methods in each smart contract cost. Refer to this google sheet:
https://docs.google.com/spreadsheets/d/1H-oZI19VDjhnS2F-I_WokHN2epi2zEu5fftTIz6lNOg/edit?usp=sharing

### Warning
The structure of this repo was taken from 1inch's liquidity-protocol repo. So there may be some leftover remains that do not apply to this project (range polling).
