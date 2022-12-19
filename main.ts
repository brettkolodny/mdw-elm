import "./style.css";
import { Elm } from "./src/Main.elm";
import { web3Accounts, web3Enable } from "@polkadot/extension-dapp";
import { ApiPromise, WsProvider } from "@polkadot/api";
import { encodeAddress } from "@polkadot/keyring";
import "./src/customComponents/address";
import "./src/customComponents/downloadEnkrypt";
import "./src/customComponents/identicon";

// Elm App
let app;

// Web3 API
let api: ApiPromise | undefined;

const elmInit = async () => {
  const extensions = (await connectWallet()).map((extension) => extension.name);

  if (process.env.NODE_ENV === "development") {
    const ElmDebugTransform = await import("elm-debug-transformer");

    ElmDebugTransform.register({
      simple_mode: true,
    });
  }

  const root = document.querySelector("#app div");
  app = Elm.Main.init({ node: root, flags: extensions });

  app.ports.sendMessage.subscribe(async ({ tag, data }) => {
    switch (tag) {
      case "network-update":
        await changeNetwork(data.network);

        if (data.extension) {
          await getAccountInfo(data.extension, data.network);
        }

        break;
      case "extension-connect":
        getAccountInfo(data.extension, undefined);
        break;
      default:
        console.error("Unhandled message: ", { tag, data });
    }
  });
};

const web3Init = async (network: any) => {
  network = network ?? "Polkadot";

  let endpoint = "wss://rpc.polkadot.io";

  if (network === "Kusama") {
    endpoint = "wss://kusama-rpc.polkadot.io";
  }

  const provider = new WsProvider(endpoint);
  const apiPromise = await ApiPromise.create({ provider });
  api = apiPromise;
};

const changeNetwork = async (network) => {
  if (api) {
    await api.disconnect();
  }

  await web3Init(network);
};

const connectWallet = async () => {
  // Wait for all extensions to inject
  await new Promise((r) => setTimeout(r, 250));

  const allInjected = await web3Enable("My Elm App");

  return allInjected;
};

const getAccountInfo = async (extensionName, network) => {
  if (!api) {
    await web3Init(network);
  }

  network = network ?? "Polkadot";

  const accounts = await web3Accounts({ extensions: [extensionName] });

  const allAccounts = accounts.map((acc) => {
    const format = network === "Polkadot" ? 0 : 2;
    return {
      address: encodeAddress(acc.address, format),
      name: acc.meta.name ?? "",
      show: false,
      balance: null,
    };
  });

  app.ports.updateAccounts.send(allAccounts);

  const balancePromises = allAccounts.map((account) => {
    return api!.query.system.account(account.address);
  });

  const balances = await Promise.all(balancePromises);

  const stakingPromises = allAccounts.map((account) => {
    return api!.query.staking.ledger(account.address);
  });

  const staking = await Promise.all(stakingPromises);

  const accountsWithBalances = allAccounts.map((account, index) => {
    const staked = staking[index].toJSON();

    let stakedAmount = 0;

    if (staked) {
      stakedAmount = (staked as any).total;
    }

    const accountBalance = {
      available: (balances[index] as any).data.free.toNumber(),
      staked: stakedAmount,
    };

    return { ...account, balance: accountBalance };
  });

  app.ports.updateAccounts.send(accountsWithBalances);
};

const main = async () => {
  await elmInit();

  await web3Init(undefined);
};

main();
