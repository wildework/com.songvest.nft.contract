const Emulator = require('../utilities/Emulator.js');
const Flow = require('../utilities/Flow.js');

describe('SongVest contract functions.', () => {
  let emulator = null;
  let accounts = null;

  beforeAll(async () => {
    emulator = new Emulator({isSilent: true});
    await emulator.loadConfiguration();
    await emulator.start();
    await emulator.initializeAccounts();
    await Flow.projectDeploy();

    accounts = emulator.flowJSON.accounts;
  });
  afterAll(async () => {
    await emulator.stop();
  });

  test('Save Collection and link capability.', async () => {
    await Flow.transactionSend({
      path: './transaction/configureAccount.cdc',
      args: [
        '--signer 0xSongVestUser'
      ]
    });
    const result = await Flow.executeScript({
      path: './tests/wasCollectionConfigured.cdc',
      args: [
        `${accounts['0xSongVestUser'].address}`,
        `${accounts['0xSongVestRandom'].address}`
      ]
    });

    expect(result.value[0].key.value).toBe(`0x${accounts['0xSongVestUser'].address}`);
    expect(result.value[0].value.value).toBe(true);

    expect(result.value[1].key.value).toBe(`0x${accounts['0xSongVestRandom'].address}`);
    expect(result.value[1].value.value).toBe(false);
  });

  test('Mint Songs with an invalid seriesNumber.', async () => {
    await Flow.transactionSend({
      path: './transaction/configureAccount.cdc',
      args: [
        '--signer 0xSongVestContract'
      ]
    });
    await Flow.transactionSend({
      path: './transaction/mintSongSeries.cdc',
      args: [
        '0',
        '"Song Title"',
        '"Writers"',
        '"Artist"',
        '"Description"',
        '"Creator"',
        '3',
        '--signer 0xSongVestContract',
      ]
    });

    const result = await Flow.executeScript({
      path: './script/getCollection.cdc',
      args: [
        `${accounts['0xSongVestContract'].address}`,
      ]
    });

    expect(result.type).toBe('Array');
    expect(result.value).toHaveLength(0);

  });

  test('Mint Songs.', async () => {
    await Flow.transactionSend({
      path: './transaction/configureAccount.cdc',
      args: [
        '--signer 0xSongVestContract'
      ]
    });
    await Flow.transactionSend({
      path: './transaction/mintSongSeries.cdc',
      args: [
        '1',
        '"Song Title"',
        '"Writers"',
        '"Artist"',
        '"Description"',
        '"Creator"',
        '3',
        '--signer 0xSongVestContract',
      ]
    });

    const result = await Flow.executeScript({
      path: './script/getCollection.cdc',
      args: [
        `${accounts['0xSongVestContract'].address}`,
      ]
    });

    expect(result.type).toBe('Array');
    expect(result.value).toHaveLength(3);
    expect(result.value[0].value).toBe('series 1 #0 ??? Song Title');
    expect(result.value[1].value).toBe('series 1 #1 ??? Song Title');
    expect(result.value[2].value).toBe('series 1 #2 ??? Song Title');
  });
});