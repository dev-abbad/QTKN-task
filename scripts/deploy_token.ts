import { QTKN, QTKN__factory } from "../typechain-types";

// scripts/deploy_upgradeable_box.js
const { ethers, upgrades } = require('hardhat');

async function main() {
    console.log('...Deploying the token');
    const Token: QTKN__factory = await ethers.getContractFactory("QTKN");
    
    // 
    const token : QTKN = await upgrades.deployProxy(Token, [] , {initializer: "initialize", kind: "transparent",});

    await token.deployed();

    const name = await token.name();

    console.log('Token Deployed to:', token.address);
    

    //now deploying the contract
}

main();
// 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575