<script>
  import { onMount } from 'svelte';

  import Home from './pages/Home.svelte';
  import Edit from './pages/Edit.svelte';

  import { ethers } from "ethers";
  import Web3Modal from "web3modal";

  import { account, containers, containerContract, containerAddress, entitiesContract, entitiesAddress, provider } from "./lib/store.js";
  import containerArtifact from '../../deployments/localhost/LoogieTank.json';
  import entitiesArtifact from '../../deployments/localhost/TreasureEntities.json';


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

    $containerAddress = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9";
    $entitiesAddress = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";

    // For paging
    window.onpopstate = () => page = document.location.hash;
    window.onhashchange = () => page = document.location.hash;
  })

  async function handleConnectWallet() {
    $account = await web3Modal.connect();

    $provider = new ethers.providers.Web3Provider($account);
    $containerContract = new ethers.Contract($containerAddress, containerArtifact.abi, $provider.getSigner());
    $containerContract.on('ContainerMinted', handleLoadContainers);

    $entitiesContract = new ethers.Contract($entitiesAddress, entitiesArtifact.abi, $provider.getSigner());

    handleLoadContainers();

    const containerCount = await $containerContract.ownerTankIds();
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

    const tx = await $containerContract.mintItem();
    await tx.wait();

    hasContainer = true;
  }

  export async function handleLoadContainers() {
    console.log('loading');

    const tokenUris = await $containerContract.ownerTankUris();

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
