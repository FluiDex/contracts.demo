const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TestBytes", function () {
  it("Express input to reversed-bit inside the returning integer", async function () {
    const TestC = await ethers.getContractFactory("TestLibs");
    const testC = await TestC.deploy();

    await testC.deployed();

    expect(await testC.testBitsOp8(0, 138)).to.equal(0);
    expect(await testC.testBitsOp8(1, 0)).to.equal(
      BigInt(
        "0x8000000000000000000000000000000000000000000000000000000000000000"
      )
    );
    expect(await testC.testBitsOp8(1, 1)).to.equal(
      BigInt(
        "0x4000000000000000000000000000000000000000000000000000000000000000"
      )
    );
    expect(await testC.testBitsOp8(42, 3)).to.equal(
      BigInt(
        "0x0A80000000000000000000000000000000000000000000000000000000000000"
      )
    );
    expect(await testC.testBitsOp8(3, 255)).to.equal(1);
    expect(await testC.testBitsOp32(1, 0)).to.equal(
      BigInt(
        "0x8000000000000000000000000000000000000000000000000000000000000000"
      )
    );
    expect(await testC.testBitsOp32(42, 3)).to.equal(
      BigInt(
        "0x0A80000000000000000000000000000000000000000000000000000000000000"
      )
    );
    expect(await testC.testBitsOp32(BigInt("0x80000001"), 225)).to.equal(
      BigInt("0x40000000")
    );
    expect(await testC.testBitsOp32(995535, 236)).to.equal(995535);
    expect(await testC.testBitsOp256(1, 0)).to.equal(
      BigInt(
        "0x8000000000000000000000000000000000000000000000000000000000000000"
      )
    );
    expect(await testC.testBitsOp256(1, 128)).to.equal(
      BigInt("0x80000000000000000000000000000000")
    );
    expect(
      await testC.testBitsOp256(BigInt("0x80000000000000000000000000000000"), 0)
    ).to.equal(BigInt("0x100000000000000000000000000000000"));
    expect(
      await testC.testBitsOp256(BigInt("0x80000000000000000000000000000000"), 1)
    ).to.equal(BigInt("0x80000000000000000000000000000000"));
    expect(
      await testC.testBitsOp256(
        BigInt("0x80000000000000000000000000000000"),
        128
      )
    ).to.equal(1);
    expect(
      await testC.testBitsOp256(
        BigInt("0x80000000000000000000000000000000"),
        129
      )
    ).to.equal(0);
  });
});

const keccak256To160 = (bytesLike) =>
  "0x" + ethers.utils.keccak256(bytesLike).slice(26);

describe("TestWriteRegistryOp", function () {
  it("Encode registry op just like circuit did", async function () {
    const TestC = await ethers.getContractFactory("TestLibs");
    const testC = await TestC.deploy();

    await testC.deployed();

    //this cases only work for acc = 4, order = 4 and balance = 3
    const expectedEncodeOp1 = keccak256To160(
      "0x91ba18348a3d7f991abc0eaee50583b0697d1fd451a039d21fa36fe748324fddc4"
    );
    const expectedEncodeOp2 = keccak256To160(
      "0x8997ad724ddb0f85f255bf087945654549ed416e131cf8719f21bb7b7ff54d7bf4"
    );
    const expectedEncodeOp3 = keccak256To160(
      "0x949c82e7b8eefc3ce0ef812304c79cba948014945150117fda5f1c0c33873099b8"
    );

    expect(
      await testC.testWriteRegistryPubdata(
        1,
        "0x5d182c51bcfe99583d7075a7a0c10d96bef82b8a059c4bf8c5f6e7124cf2bba3"
      )
    ).to.equal(expectedEncodeOp1);
    expect(
      await testC.testWriteRegistryPubdata(
        2,
        "0xe9b54eb2dbf0a14faafd109ea2a6a292b78276c8381f8ef984dddefeafb2deaf"
      )
    ).to.equal(expectedEncodeOp2);
    expect(
      await testC.testWriteRegistryPubdata(
        5,
        "0x3941e71d773f3c07f781c420e3395d290128298a0a88fe5bfa3830cce10c991d"
      )
    ).to.equal(expectedEncodeOp3);
  });
});

describe("TestWriteDepositOp", function () {
  it("Encode deposit op just like circuit did", async function () {
    const TestC = await ethers.getContractFactory("TestLibs");
    const testC = await TestC.deploy();

    await testC.deployed();

    //this cases only work for acc = 4, order = 4 and balance = 3
    const expectedEncodeOp1 = keccak256To160(
      "0x111000452958b80000000000000000000000000000000000000000000000000000"
    );

    expect(
      await testC.testWriteDepositPubdata(1, 1, BigInt("500000000000"))
    ).to.equal(expectedEncodeOp1);
  });
});
