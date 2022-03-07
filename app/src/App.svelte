<script>
  import { onMount } from 'svelte';

  import containerArtifact from '../../artifacts/src/Container/LoogieTank.sol/LoogieTank.json'

  import { ethers } from "ethers";


  const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const HARDHAT_NETWORK_ID = '1337';
  const ERROR_CODE_TX_REJECTED_BY_USER = 4001;

  const initialState = {
    tokenData: undefined,
    selectedAddress: undefined,
    balance: undefined,
    txBeingSent: undefined,
    transactionError: undefined,
    networkError: undefined,
  };

  let account, connectionState, _provider, _token;
  let display, displayLoaded = false;
  let hasContainer = false;



  onMount(async () => {
    connectionState = initialState;
  })

  async function handleConnectWallet() {
    const [selectedAddress] = await window.ethereum.request({ method: 'eth_requestAccounts' });

    if (!_checkNetwork()) {
      console.error('Wrong network', window.ethereum.networkVersion)
      return;
    }

    _initialize(selectedAddress);

    window.ethereum.on("accountsChanged", ([newAddress]) => {
      if (newAddress === undefined) {
        return _resetState();
      }

      _initialize(newAddress);
    });

    window.ethereum.on("chainChanged", ([networkId]) => {
      _resetState();
    });
  }

  function _initialize(userAddress) {
    connectionState.selectedAddress = userAddress;

    _initializeEthers();
    _getTokenData();
  }

  async function _initializeEthers() {
    _provider = new ethers.providers.Web3Provider(window.ethereum);

    _token = new ethers.Contract(
      CONTRACT_ADDRESS,
      containerArtifact.abi,
      _provider.getSigner(0)
    );
  }

  function _resetState() {
    connectionState = initialState;
  }

  async function _getTokenData() {
    const name = await _token.name();
    const symbol = await _token.symbol();

    connectionState.tokenData = {name, symbol};
  }

  function _checkNetwork() {
    if (window.ethereum.networkVersion === HARDHAT_NETWORK_ID) {
      return true;
    }

    connectionState.networkError = 'Please connect Metamask to Localhost:8545';
    return false;
  }

  async function handleCreateContainer() {
    try {
      _dismissTransactionError();

      const tx = await _token.mintItem();
      connectionState.txBeingSent = tx.hash;
      const receipt = await tx.wait();

      if (receipt.status === 0) {
        throw new Error("Transaction failed");
      }

      // handleLoadContainers();
    } catch (error) {
      if (error.code === ERROR_CODE_TX_REJECTED_BY_USER) {
        return;
      }

      console.error(error);
      connectionState.transactionError = error;
    } finally {
      connectionState.txBeingSent = undefined;
    }
  }

  function _dismissTransactionError() {
    connectionState.transactionError = undefined;
  }

  async function handleLoadContainers() {
    console.log('loading');

    const provider = wallet.getProvider();

    const containerContract = new ethers.Contract(containerAddress, containerArtifact.abi, provider);
    const tokenUri = await containerContract.tokenURI(1);

    console.log(tokenUri);
    display.innerHTML = tokenUri;
  }
</script>


<main>
  {#if (!account)}
    <button on:click={handleConnectWallet}>Connect</button>
  {/if}

  {#if (!hasContainer)}
    <button on:click={handleCreateContainer}>Create container</button>
  {:else}
    <button on:click={handleLoadContainers}>Load Container</button>
    <div bind:this={display}></div>
  {/if}
</main>
