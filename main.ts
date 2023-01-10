// IMPORTS --------------------------------------------------------------------

import "./style.css";
// @ts-ignore
import { Elm } from "./src/Main.elm";
import {
  web3Accounts,
  web3Enable,
  web3FromAddress,
} from "@polkadot/extension-dapp";
import { ApiPromise, WsProvider } from "@polkadot/api";
import { encodeAddress } from "@polkadot/keyring";
import "./src/customComponents/address";
import "./src/customComponents/downloadEnkrypt";
import "./src/customComponents/identicon";

// TYPES ----------------------------------------------------------------------

type PortMsg =
  | { tag: "network-update"; data: { network: Network; extension: string } }
  | { tag: "extension-connect"; data: { extension: string } }
  | { tag: "send-preview"; data: SendData }
  | { tag: "send-tokens"; data: SendData };

interface AccountInfo {
  address: string;
  name: string;
  show: boolean;
  balance: Balance | null;
}

interface Balance {
  available: any;
  staked: number;
}

interface ElmPorts {
  sessionMessage: PortFromElm<PortMsg>;
  sendMessage: PortFromElm<PortMsg>;
  updateAccounts: PortToElm<AccountInfo[]>;
  transactionPreview: PortToElm<number>;
  sendTransactionDeclined: PortToElm<null>;
  sendTransactionSuccess: PortToElm<null>;
}

type Network = "Polkadot" | "Kusama";

interface SendData {
  from: string;
  to: string;
  amount: number;
}

// STORAGE --------------------------------------------------------------------

const setLastExtension = (extensionName: string) => {
  window.localStorage.setItem("extension", extensionName);
};

const getLastExtension = () => {
  return window.localStorage.getItem("extension");
};

// GLOBAL STATE ---------------------------------------------------------------

let app: ElmApp<ElmPorts>;

let api: ApiPromise | undefined;

// SETUP ----------------------------------------------------------------------

const elmInit = async () => {
  const extensions = (await connectWallet()).map((extension) => extension.name);
  const currentExtension = getLastExtension() ?? "connect";

  if (process.env.NODE_ENV === "development") {
    const ElmDebugTransform = await import("elm-debug-transformer");

    ElmDebugTransform.register({
      simple_mode: true,
    });
  }

  const root = document.querySelector("#app div");
  app = Elm.Main.init({
    node: root,
    flags: { extensions, currentExtension: currentExtension },
  });

  subscribeSessionPort();
  subscribeSendPort();
};

const web3Init = async (network: Network | undefined) => {
  network = network ?? "Polkadot";

  let endpoint = "wss://rpc.polkadot.io";

  if (network === "Kusama") {
    endpoint = "wss://kusama-rpc.polkadot.io";
  }

  const provider = new WsProvider(endpoint);
  const apiPromise = await ApiPromise.create({ provider });
  api = apiPromise;
};

// ELM PORTS ------------------------------------------------------------------

const subscribeSessionPort = () => {
  app.ports.sessionMessage.subscribe(async ({ tag, data }) => {
    switch (tag) {
      case "network-update":
        await changeNetwork(data.network);

        if (data.extension) {
          await getAccountInfo(data.extension, data.network);
        }

        break;
      case "extension-connect":
        setLastExtension(data.extension);
        getAccountInfo(data.extension, undefined);
        break;
      default:
        console.error("Unhandled message from session port: ", { tag, data });
    }
  });
};

const subscribeSendPort = () => {
  app.ports.sendMessage.subscribe(async ({ tag, data }) => {
    switch (tag) {
      case "send-preview":
        getTransactionPreview(data);
        break;
      case "send-tokens":
        sendTokens(data);
        break;
      default:
        console.error("Unhandled message from send port: ", { tag, data });
    }
  });
};

// PORT CALLBACKS -------------------------------------------------------------

const changeNetwork = async (network: Network) => {
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

const getAccountInfo = async (
  extensionName: string,
  network: Network | undefined
) => {
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

const getTransactionPreview = async (sendData: SendData) => {
  if (!api) {
    console.error("Web3 API not initialized");
    return;
  }

  try {
    const info = await api?.tx.balances
      .transfer(sendData.to, sendData.amount)
      .paymentInfo(sendData.from);

    app.ports.transactionPreview.send(info.partialFee.toJSON());
  } catch (e) {
    console.error(e);
  }
};

const sendTokens = async (sendData: SendData) => {
  if (!api) {
    console.error("Web3 API not initialized");
    return;
  }

  try {
    const injector = await web3FromAddress(sendData.from);

    await api.tx.balances
      .transferKeepAlive(sendData.to, sendData.amount)
      .signAndSend(sendData.from, { signer: injector.signer });

    app.ports.sendTransactionSuccess.send(null);
  } catch (e) {
    app.ports.sendTransactionDeclined.send(null);
    console.error(e);
  }
};

// MAIN -----------------------------------------------------------------------

const main = async () => {
  // Waits to give time for extensions to inject
  await new Promise((r) => setTimeout(r, 500));

  await elmInit();

  await web3Init(undefined);

  const lastExtension = getLastExtension();

  if (lastExtension) {
    getAccountInfo(lastExtension, undefined);
  }
};

main();
