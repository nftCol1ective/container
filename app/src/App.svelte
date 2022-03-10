<script>
  import { onMount } from 'svelte';

  import Home from './pages/Home.svelte';
  import Edit from './pages/Edit.svelte';

  import { ethers } from "ethers";
  import Web3Modal from "web3modal";

  import { account, containers, containerContract, provider } from "./lib/store.js";
  import containerArtifact from '../../deployments/localhost/LoogieTank.json';
  import entitiesArtifact from '../../deployments/localhost/TreasureEntities.json';

  import { decodeTokenUri } from "./lib/utils.js";


  const CONTAINER_ADDRESS = "0xFd6b2fCE02ccAbF4273674fEAd5BDBB369FCF3F0";

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

    // For paging
    window.onpopstate = () => page = document.location.hash;
    window.onhashchange = () => page = document.location.hash;
  })

  async function handleConnectWallet() {
    $account = await web3Modal.connect();

    $provider = new ethers.providers.Web3Provider($account);
    $containerContract = new ethers.Contract(CONTAINER_ADDRESS, containerArtifact.abi, $provider.getSigner());
    $containerContract.on('ContainerMinted', handleLoadContainers);

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
    tokenUris.forEach((uri) => {
      $containers = [...$containers, decodeTokenUri(uri)]
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
    <Edit entitiesArtifact="{entitiesArtifact}" />
  {:else}
    <Home bind:hasContainer on:createContainer={handleCreateContainer} on:loadContainers={handleLoadContainers} />
  {/if}
</main>
