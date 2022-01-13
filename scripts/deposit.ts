import * as fs from 'fs';
import { Account } from "fluidex.js";
import { ethers } from "hardhat";
//import * as hre from "hardhat";
import { getTestAccount } from "./accounts";
import { assert } from 'chai';

const loadAccounts = () => Array.from(botsIds).map((user_id) => Account.fromMnemonic(getTestAccount(user_id).mnemonic));
const botsIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19];
const accounts = loadAccounts();

interface Token {
  symbol: string,
  address: string,
}

const Erc20Abi = [
    // Read-Only Functions
    "function balanceOf(address owner) view returns (uint256)",
    "function allowance(address owner, address spender) view returns (uint256)",
    "function decimals() view returns (uint8)",
    "function symbol() view returns (string)",

    // Authenticated Functions
    "function transfer(address to, uint amount) returns (bool)",
    "function approve(address spender, uint amount) returns (bool)",

    // Events
    "event Transfer(address indexed from, address indexed to, uint amount)"
];

let tokens: Token[];
const raw = fs.readFileSync('tokens.json', 'utf-8');
tokens = JSON.parse(raw);

async function deploy_account(userId: number, account: Account) {

  let acc_wallet = ethers.Wallet.fromMnemonic(getTestAccount(userId).mnemonic);
  let acc_address = await acc_wallet.getAddress();
  assert(account.ethAddr == acc_address, "same account");
  let acc_l2 = account.bjjPubKey;

  acc_wallet = acc_wallet.connect(ethers.provider);
  let ethBalance = await acc_wallet.getBalance();
  console.log("eth balance of ", acc_address, ethBalance.toString());
  assert(account.ethAddr == acc_address, "same account");

  const delegateAddress = process.env.CONTRACT_ADDR;
  console.log("delegate contract at:", delegateAddress);
  const contract = await ethers.getContractAt("FluiDexDelegate", delegateAddress as string, acc_wallet);  

  for (const {symbol, address} of Array.from(tokens)) {
    //suppose all symbol use prec as 6
    let depositAmount = symbol == 'USDT' ? BigInt('500000000000') : BigInt('10000000');
    console.log(`Find ${symbol} at`, address);
  
    let erc20 = new ethers.Contract(address, Erc20Abi, acc_wallet);
    let ercBalance = await erc20.functions.balanceOf(acc_address);
    console.log(`${acc_address}'s balance of ${symbol}`, ercBalance.toString());

    let allowedBalanced = await erc20.functions.allowance(acc_address, delegateAddress);
    if (allowedBalanced < depositAmount){
        console.log(`no enough allowed balance: expected ${depositAmount} but only ${allowedBalanced}`),
        await erc20.functions.approve(delegateAddress, depositAmount);
    }
    
    await contract.functions.depositERC20(address, acc_l2, depositAmount);
  }
  await contract.functions.depositETH(acc_l2, {value: ethers.utils.parseEther("0.6")} /* overrides */);

}


async function main() {

  for(const [idx, account] of accounts.entries()) {
    await deploy_account(idx + 1, account);
  }

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
