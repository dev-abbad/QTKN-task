import { QTKN, QTKN__factory } from "../typechain-types";

// scripts/deploy_upgradeable_box.js
const { ethers, upgrades } = require('hardhat');

async function main() {
    
    const NFT = await ethers.getContractFactory("Nft");
    console.log('...Deploying the token');
    // 
    const nft = await upgrades.deployProxy(NFT, [] , {initializer: "initialize", kind: "transparent",});

    await nft.deployed();

    const name = await nft.name();

    console.log('Token Deployed to:', nft.address);
    

    //now deploying the contract
}

main();
//0xC9a43158891282A2B1475592D5719c001986Aaec