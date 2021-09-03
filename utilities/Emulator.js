const fs = require('fs');
const child_process = require('child_process');

const Flow = require('./Flow.js');

const constants = {
  flowJSON: {
    path: 'flow.json'
  }
};

function parseOutput(data) {
  const propsExpression = /(\w+)=([^\s|^"]+)|(\w+)="([^"]+)"/g;
  const lines = data.split('\n').filter((line) => line.length > 0);
  
  const result = [];

  for (const line of lines) {
    const props = {};

    let match = null;
    do {
      match = propsExpression.exec(line);
      if (match !== null) {
        if (match[1] !== undefined) {
          // Matched key=value.
          props[match[1]] = match[2];
        } else {
          // Matched key="value".
          props[match[3]] = match[4];
        }
      }
    } while (match)

    result.push(props);
  }

  return result;
};

class Emulator {
  constructor(options = {}) {
    this.subprocess = null;
    this.isSilent = options.isSilent || false;
    this.isRunning = null;
    this.flowJSON = null;
  }

  loadConfiguration() {
    // Make sure that flow.json has been initialized.
    try {
      fs.accessSync(constants.flowJSON.path, fs.constants.R_OK | fs.constants.W_OK);
    } catch (error) {
      fs.writeFileSync(
        'flow.json',
        fs.readFileSync('./base.flow.json', 'utf-8'),
        'utf-8'
      );
    }

    this.flowJSON = JSON.parse(
      fs.readFileSync('./flow.json', 'utf-8')
    );
  }
  storeConfiguration() {
    fs.writeFileSync(
      'flow.json',
      JSON.stringify(this.flowJSON),
      'utf-8'
    );
  }

  async start() {
    this.loadConfiguration();

    // Spawn subprocess.
    this.subprocess = child_process.spawn(
      'flow',
      [
        'emulator',
        'start'
      ]
    );

    // Attach listeners.
    this.subprocess.stdout.on('data', (data) => {
      const parsed = parseOutput(data.toString());
      for (const props of parsed) {
        if (props.msg.includes('Starting HTTP server')) {
          this.isRunning = true;
        } else if (props.msg.includes('Server error')) {
          console.log(data.toString());
        }

        if (!this.isSilent) {
          console.log(props.msg);
        }
      }
    });
    this.subprocess.stderr.on('data', (data) => {
      console.error(data.toString());
      this.isRunning = false;
      this.stop();
    });
    this.subprocess.on('error', (error) => {
      console.error(error);
      this.isRunning = false;
      this.stop();
    });
    this.subprocess.on('close', (code) => {
      this.isRunning = false;
      if (code !== 0) {
        console.error(code);
      }
    });

    do {
      await new Promise((resolve) => setTimeout(resolve, 50));
    } while (this.isRunning === null)
  }
  async initializeAccounts() {
    for (const accountName in this.flowJSON.accounts) {
      if (accountName.startsWith('0xSongVest')) {
        const account = this.flowJSON.accounts[accountName];
  
        // Create new accounts for testing.
        const keys = await Flow.keysGenerate();
        const flowAccount = await Flow.accountsCreate({publicKey: keys.public});
        //console.log(`Configured ${accountName} -> ${flowAccount.address}.`);
  
        const configuredAccount = {
          ...account,
          key: {
            ...account.key,
            privateKey: keys.private
          },
          address: flowAccount.address,
          name: accountName
        };
        this.flowJSON.accounts[accountName] = configuredAccount;
      }
    }

    this.storeConfiguration();
  }
  async stop() {
    if (this.subprocess) {
      this.subprocess.kill();
      do {
        await new Promise((resolve) => setTimeout(resolve, 50));
      } while (this.isRunning)
    }
  }
}

module.exports = Emulator;