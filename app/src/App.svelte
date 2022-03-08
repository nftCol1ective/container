<script>
  import { onMount } from 'svelte';

  import Home from './pages/Home.svelte';
  import Edit from './pages/Edit.svelte';

  import { ethers } from "ethers";
  import Web3Modal from "web3modal";

  import { account, containers, contract, provider } from "./lib/store.js";
  import containerArtifact from '../../deployments/localhost/LoogieTank.json';


  const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

  const providerOptions = {
    /* See Provider Options Section */
  };

  const web3Modal = new Web3Modal({
    network: "mainnet", // optional
    cacheProvider: false, // optional
    providerOptions // required
  });

  let page;
  let hasContainer = false;


  onMount(async () => {
    page = document.location.hash;

    window.onpopstate = () => page = document.location.hash;
    window.onhashchange = () => page = document.location.hash;
  })

  async function handleConnectWallet() {
    $account = await web3Modal.connect();

    $provider = new ethers.providers.Web3Provider($account);
    $contract = new ethers.Contract(CONTRACT_ADDRESS, containerArtifact.abi, $provider.getSigner());
    $contract.on('ContainerMinted', handleLoadContainers);

    handleLoadContainers();

    const containerCount = await $contract.ownerTankIds();
    hasContainer = containerCount.length > 0;

    $provider.on("accountsChanged", (accounts) => {
      console.log(accounts);
    });

    $provider.on("chainChanged", (chainId) => {
      console.log(chainId);
    });

    $provider.on("connect", (info) => {
      console.log(info);
    });

    $provider.on("disconnect", (error) => {
      console.log(error);
    });
  }

  export async function handleCreateContainer() {
    console.log('creating');

    const tx = await $contract.mintItem();
    await tx.wait();

    hasContainer = true;
  }

  export async function handleLoadContainers() {
    console.log('loading');

    const tokenUris = await $contract.ownerTankUris();

    $containers = [];
    let decoded;
    let metadata;

    tokenUris.forEach((uri) => {
      decoded = atob(uri.split(',')[1]);
      metadata = JSON.parse(decoded);
      metadata.image = atob(metadata.image.split(',')[1])
      $containers = [...$containers, metadata]
    })
  }
</script>


<style>
  main {
    display: grid;
    justify-items: center;
    gap: 10px;
  }
</style>


<main>
  <h1>NFT Dashboard</h1>

  {#if (!$account)}
    <button on:click={handleConnectWallet}>Connect</button>
  {/if}

  {#if (page?.startsWith('#edit'))}
    <Edit />
  {:else}
    <Home bind:hasContainer on:createContainer={handleCreateContainer} on:loadContainers={handleLoadContainers} />
  {/if}
</main>
