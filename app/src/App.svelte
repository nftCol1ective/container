<script>
  import { onMount } from 'svelte';

  import containerArtifact from '../../deployments/localhost/LoogieTank.json';

  import { ethers } from "ethers";
  import Web3Modal from "web3modal";


  const CONTRACT_ADDRESS = "0x68B1D87F95878fE05B998F19b66F4baba5De1aed";

  const providerOptions = {
    /* See Provider Options Section */
  };

  const web3Modal = new Web3Modal({
    network: "mainnet", // optional
    cacheProvider: false, // optional
    providerOptions // required
  });

  let account, connectionState;
  let tanks = [];
  let hasContainer = false;


  onMount(async () => {
  })

  async function handleConnectWallet() {
    account = await web3Modal.connect();

    const provider = new ethers.providers.Web3Provider(account);
    const contract = new ethers.Contract(CONTRACT_ADDRESS, containerArtifact.abi, provider.getSigner());

    const containerCount = await contract.ownerTankIds();
    hasContainer = containerCount.length > 0;
    console.log('containerCount', containerCount)
  }

  async function handleCreateContainer() {
    console.log('creating');

    const provider = new ethers.providers.Web3Provider(account);
    const contract = new ethers.Contract(CONTRACT_ADDRESS, containerArtifact.abi, provider.getSigner());

    const tx = await contract.mintItem();
    const state = tx.hash;
    const receipt = await tx.wait();

    hasContainer = true;

    console.log('created', state, receipt)
  }

  async function handleLoadContainers() {
    console.log('loading');

    const provider = new ethers.providers.Web3Provider(account);
    const containerContract = new ethers.Contract(CONTRACT_ADDRESS, containerArtifact.abi, provider.getSigner());
    const tokenUris = await containerContract.ownerTankUris();

    tanks = [];
    let encoded;
    let metadata;
    tokenUris.forEach((uri) => {
      encoded = atob(uri.split(',')[1]);
      metadata = JSON.parse(encoded);
      tanks = [...tanks, atob(metadata.image.split(',')[1])]
    })
  }
</script>


<main>
  {#if (!account)}
    <button on:click={handleConnectWallet}>Connect</button>
  {:else}
    <button on:click={handleCreateContainer}>Create container</button>
    {#if hasContainer}
      <button on:click={handleLoadContainers}>Load Container</button>
      <ul>
        {#each tanks as tank}
          <li>{@html tank}</li>
        {/each}
      </ul>
    {/if}
  {/if}
</main>
