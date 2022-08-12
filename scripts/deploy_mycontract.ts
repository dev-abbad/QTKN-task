import { QTKN, QTKN__factory } from "../typechain-types";

const { ethers, upgrades } = require('hardhat');

async function main() {

    // 0x610178dA211FEF7D417bC0e6FeD39F05609AD788
    const addresses = await ethers.getSigners();
    const Token = await ethers.getContractFactory("QTKN");
    const token = await Token.attach("0x610178dA211FEF7D417bC0e6FeD39F05609AD788");

    //0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e
    const Nft = await ethers.getContractFactory("Nft");
    const nft = await Nft.attach("0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e");

    const Mycontract = await ethers.getContractFactory("Mycontract");

    const mycontract = await upgrades.deployProxy(Mycontract, [token.address, nft.address], { initializer: "initialize", kind: "transparent", unsafeAllow: ['delegatecall'] });
    await mycontract.deployed();

    console.log('Mycontract Deployed to:', mycontract.address);
    console.log("Name of the token is:", await mycontract.getTokenName());
    console.log("Name of the NFT contract is:", await mycontract.getNftName());


    //address 1 and 2 are teachers
    const txt1 = await mycontract.addTeachers(addresses[1].address);
    await txt1.wait();
    const txt2 = await mycontract.addTeachers(addresses[2].address);
    await txt2.wait();

    //adding a course through address 1
    await mycontract.connect(addresses[1]).addCourse("OOP", 100, 80, 20);
    await mycontract.connect(addresses[1]).addCourse("Data Structres", 100, 80, 20);

    //seeing the first course
    const course = await mycontract.returnCourse(0);
    console.log("course id: ", course[0],
        "course base price: ", course[1],
        "course price: ", course[2],
        "course minter: ", course[3],
        "course owner: ", course[4],
        "course name: ", course[5]);

    //purchasing tokens through account 3
    const txt3 = await mycontract.connect(addresses[3]).buyTokens({ value: ethers.utils.parseEther("2") });
    await txt3.wait();

    //purchasing tokens through account 4
    const txt4 = await mycontract.connect(addresses[4]).buyTokens({ value: ethers.utils.parseEther("2") });
    await txt4.wait();


    //showing balance through QTKN contract
    console.log("balance of account 3 through mytoken", await token.balanceOf(addresses[3].address));
    const txt6 = await mycontract.mintTokens();
    await txt6.wait();

    //showing balance through QTKN contract
    console.log("balance after minting");
    console.log("balance of account 3 through mytoken", await token.balanceOf(addresses[3].address));

    const txt7 = await mycontract.connect(addresses[3]).buyNft(0);
    await txt7.wait();

    const txt8 = await mycontract.connect(addresses[4]).buyNft(1);
    await txt8.wait();

    console.log("balance of account 3 through mytoken", await token.balanceOf(addresses[3].address));
    console.log("balance of account 1 through mytoken", await token.balanceOf(addresses[0].address));

    console.log("Owner of the course OOP is:",  await mycontract.showOwner("OOP"));
    console.log("Owner of the course OOP through nft contract is:",  await nft.ownerOf(0));

    console.log("Owner of the course Data Structures is:",  await mycontract.showOwner("Data Structres"));
    console.log("Owner of the course Data Structures through nft contract is:",  await nft.ownerOf(1));

    // const txt8 = await mycontract.connect(addresses[4]).buyNft(0);
    // await txt8.wait();



    // const txt6 = await mycontract.connect(addresses[3]).buyCourse(0);
    // await txt6.wait();

    // console.log("Account 4 has bought the course with course with course_id 1 i.e oop");

    // console.log("balance of account 4 through mytoken", await token.balanceOf(addresses[3].address));

    const course1 = await mycontract.returnCourse(0);
    console.log("course id: ",course1[0],
    "course base price: ",course1[1],
    "course price: ",course1[2],
    "course minter: ",course1[3],
    "course owner: ",course1[4],
    "course name: ",course[5]);




    // const name = await mycontract.getName();
    // console.log("name of contract", name);





}
main();

