const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("hack_bean", function () {

  it("i dont know what is it." , async function () {

    const poc = await ethers.getContractFactory("hack_bean");
    const poc_test = await poc.deploy();

    await poc_test.deployed();

    console.log("poc_test deployed to:", poc_test.address);

    // await poc_test.get_balance_WETH();

    // await poc_test.set_all_approve();
  });
});
