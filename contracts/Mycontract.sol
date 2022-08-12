// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "./QTKN.sol";
import "./NFT.sol";

contract Mycontract is Initializable, OwnableUpgradeable {
    //library for keeping track of token_id
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct Course {
        uint256 course_id;
        uint256 base_price;
        uint256 course_price;
        address minter;
        address owner;
        string course_name;
    }

    QTKN public mytoken;
    Nft public mynft;
    mapping(address => uint8) public teachers;
    address[] public pending_balances_owners;
    mapping(string=>address) name_to_owner;

    Course[] public courses;
    //mapping(uint256=>address) public token_id_to_owner;
    mapping(uint256 => Course) public id_to_course;
    CountersUpgradeable.Counter private token_id;

    mapping(address => uint256) private pending_balances;


    function initialize(QTKN _token, Nft _nft) public initializer {
        mytoken = _token;
        mynft = _nft;
        __Ownable_init();
    }

    function addTeachers(address _teacher) public onlyOwner {
        teachers[_teacher] = 1;
    }

    function getTokenName() public view returns (string memory) {
        return mytoken.name();
    }

    function getNftName() public view returns (string memory) {
        return mynft.name();
    }

    function addCourse(
        string memory _course_name,
        uint256 _base_price,
        uint256 _school_share,
        uint256 _teacher_share
    ) public {
        require(
            _school_share + _teacher_share == 100,
            "Shares not equaling to 100"
        );
        require(teachers[msg.sender] == 1, "Only teachers can add the courses");

        uint256 tax = (_base_price * 3) / 100;
        uint256 _share = (_base_price * _school_share) / 100;
        console.log("Tax of course is", tax);

        uint256 price = tax + _base_price + _share;

        courses.push(
            Course({
                course_id: token_id.current(),
                base_price: _base_price,
                course_price: price,
                minter: msg.sender,
                owner: OwnableUpgradeable.owner(),
                course_name: _course_name
            })
        );

        id_to_course[token_id.current()] = courses[token_id.current()];

        token_id.increment();

        //mynft.safeMint(msg.sender);
    }

    function returnCourse(uint256 _token_id)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            address,
            string memory
        )
    {
        return (
            courses[_token_id].course_id,
            courses[_token_id].base_price,
            courses[_token_id].course_price,
            courses[_token_id].minter,
            courses[_token_id].owner,
            courses[_token_id].course_name
        );
    }

    function buyTokens() public payable {

        pending_balances[msg.sender] += uint256(msg.value) / 10**16;
        bool check = false;
        for (uint256 i = 0; i < pending_balances_owners.length; i++) {
            if (pending_balances_owners[i] == msg.sender) {
                check = true;
                break;
            }
        }
        if (check == false) {
            pending_balances_owners.push(msg.sender);
        }
    }

    function mintTokens() public onlyOwner {
        address to;
        for (uint256 i = pending_balances_owners.length - 1; i > 0; i--) {
            to = pending_balances_owners[i];
            mytoken.mint(to, pending_balances[to]);
            pending_balances[to] = 0;
            pending_balances_owners.pop();
            console.log("i", i, "length", pending_balances_owners.length);
        }
        to = pending_balances_owners[0];
        mytoken.mint(to, pending_balances[to]);
    }

    function buyNft(uint256 _course_id)public{
        require(id_to_course[_course_id].course_price <= uint256(mytoken.balanceOf(msg.sender)),"balance not enough");
        mytoken.transfer(msg.sender,OwnableUpgradeable.owner(),id_to_course[_course_id].course_price);
        require(id_to_course[_course_id].owner == OwnableUpgradeable.owner(),"NFT has already been bought");
        name_to_owner[id_to_course[_course_id].course_name] = msg.sender;
        mynft.safeMint(msg.sender);
        id_to_course[_course_id].owner = msg.sender;
    }

    function showOwner(string memory course_name)public view returns(address){
        return name_to_owner[course_name];
    }


    function showBalance() public view returns (uint256) {
        return mytoken.balanceOf(msg.sender);
    }
}
