const util = require('util');
const child_process = require('child_process');

const exec = util.promisify(child_process.exec);

async function keysGenerate() {
  const result = await exec(
    [
      `flow keys generate`,
      `--sig-algo ECDSA_secp256k1`,
      `--output json`,
    ].join(' ')
  );
  return JSON.parse(result.stdout);
}
async function accountsCreate({publicKey} = {}) {
  const result = await exec(
    [
      `flow accounts create`,
      `--key "${publicKey}"`,
      `--sig-algo "ECDSA_secp256k1"`,
      `--signer "emulator-account"`,
      `--output json`,
    ].join(' ')
  );
  if (result.stderr.length === 0) {
    return JSON.parse(result.stdout);
  } else {
    return null;
  }
}
async function projectDeploy() {
  const result = await exec(
    [
      `flow project deploy`,
      `--output json`,
    ].join(' ')
  );
  return JSON.parse(result.stdout);
}
async function executeScript({path, args} = {path: '', args: []}) {
  const result = await exec(
    [
      `flow scripts execute ${path}`,
      ...args,
      `--output json`
    ].join(' ')
  );
  return JSON.parse(result.stdout);
}
async function transactionSend({path, args} = {path: '', args: []}) {
  const result = await exec(
    [
      `flow transactions send ${path}`,
      ...args,
      `--output json`
    ].join(' ')
  );
  return JSON.parse(result.stdout);
}
async function getTransaction(id) {
  const result = await exec(
    [
      `flow transactions get ${id}`,
      `--output json`,
      `--sealed`
    ].join(' ')
  );
  // return result.stdout;
  return JSON.parse(result.stdout);
}

module.exports = {
  keysGenerate,
  accountsCreate,
  projectDeploy,
  executeScript,
  transactionSend,
  getTransaction
};