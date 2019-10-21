# Fair Rice Trade
Fair rice trade is a blockchain fintech solution for rice, and potentially
other crops, focused on creating a systematic social economic impact in
developing countries.

## Installation
This system uses `truffle` and `npm` packages.
Setup the system using:
```
npm install
truffle compile
```

Configure your corresponding truffle network in `truffle-config.js` and deploy using:
```
truffle deploy
```
This will deploy a simulated `DAI` token (assumption using DAI from MakerDAO in a live contract) for testnet,
and the rice trading contract `Trade.sol`

## Setup steps
- During the deployment of `Trade.sol`, address of the DAI address needs to be passed.
- Create a `region_id` using `create_region()`. Should be a positive integer.
- Onboard the farmer using `onboard_farmer()` using the farmer's address, `region_id` and an estimated `land_size` in m2.
- Oboard the middleman and ricemiller using `onboard_middleman()` and `onboard_ricemill()` and their respective addresses.
- Farmer can create a new harvest using `new_harvest()`, which will return a `harvest_id`
- Farmer can optionally should agree on a pre-payment with the middleman and request the middleman to provide pre-payment using `provide_prepayment()`
  - Middleman should call ERC20 `approve()` on the prepayment amount to the Trade contract, followed by `provide_prepayment()`
- During harvest time, farmer should confirm on his accepted price using `farmer_confirm_price()`
- Middleman should call `approve()` and `middleman_payment()` to pay to farmer.
  - If there was any pre-payment, only that middleman will be allowed to make final payment, and the final price will exclude the pre-paid amount.
- Middleman can agree on an accepted price from rice mill using `middleman_confirm_millprice()`
- ricemill will call `approve()` and `ricemiller_payment()` to make payment to middleman. This completes one trade cycle.

## Basic documentation

### Trade roles
The smart contract in `Trade.sol` describes 4 roles:
- `platform` is the owner, and is able to create regions, and onboard farmers, middleman and rice mills.
- `farmer` role can receive prepayment, and final payment
- `middleman` optionally provides pre-payment to farmers, and buys the rice from farmer after harvest.
- `ricemill` buys the rice from `middleman`
