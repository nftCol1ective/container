<script>
  import { onMount } from 'svelte';

  import Home from './pages/Home.svelte';
  import Edit from './pages/Edit.svelte';

  import { ContractFactory, ethers } from "ethers";
  import Web3Modal from "web3modal";

  import { account, containers, CONTAINER_ADDRESS, localContainerContract, containerContract, provider, entitiesContract } from "./lib/store.js";
  import containerArtifact from '../../deployments/localhost/LoogieTank.json';
  import entitiesArtifact from '../../deployments/localhost/TreasureEntities.json';

  import { decodeTokenUri } from "./lib/utils.js";


  let  providerOptions = {
    /* See Provider Options Section */
  };

  const web3Modal = new Web3Modal({
    network: "mainnet", // optional
    cacheProvider: false, // optional
    providerOptions // required
  });

  let page;
  let hasContainer = false;


  onMount(() => {
    page = document.location.hash;

    // For paging
    window.onpopstate = () => page = document.location.hash;
    window.onhashchange = () => page = document.location.hash;
  })

  async function handleConnectWallet() {
    $account = await web3Modal.connect();

    $provider = new ethers.providers.Web3Provider($account);
    $containerContract = new ethers.Contract(CONTAINER_ADDRESS, containerArtifact.abi, $provider.getSigner());
    $containerContract.once('ContainerMinted', handleLoadContainers);

    const containerCount = await $localContainerContract.ownerTankIds();
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

  async function handleSetupContainer(event) {
    console.log('creating');

    await handleConnectWallet();

    const containerType = event.detail.type;
    const selectedToken = toNumberArray(event.detail.tokens);

    // const factory = new ContractFactory(containerArtifact.abi, containerArtifact.bytecode, $provider.getSigner());
    // const tankId = await factory.setupNewContainer(containerType, selectedToken, getDefaultAmounts(selectedToken));
    // await tankId.deployTransaction.wait();

    const tx = await $containerContract.setupNewContainer(containerType, selectedToken, getDefaultAmounts(selectedToken));
    await tx.wait();

    console.log(tx.value.toNumber());
    window.location.hash = `edit/${tx.value.toNumber()}`;
  }

  export async function handleLoadContainers() {
    console.log('loading');

    const tokenUris = await $containerContract.ownerTankUris();

    $containers = [];
    tokenUris.forEach((uri) => {
      $containers = [...$containers, decodeTokenUri(uri)]
    })
  }

  async function handleCreateItemset() {
    console.log('creating itemset')

    if (!$entitiesContract) {
      const factory = new ContractFactory(entitiesArtifact.abi, entitiesArtifact.bytecode, $provider.getSigner());
      const contract = await factory.deploy("");
      await contract.deployTransaction.wait();

      // $entities = requestAvailableEntities();
      $entitiesContract = contract;

      $containerContract.setEntityContractAddress(contract.address);

      console.log('created', $entitiesContract.address);
    } else {
      console.error('entity already exists')
    }
  }

  async function transferEntity(id) {
    console.log(`transfer ${id}`);

    const tx = await $entitiesContract.safeTransferFrom($provider.getSigner().getAddress(),
      $containerContract.address, id, 1, [1]);
    await tx.wait();
  }

  function toNumberArray(array) {
    return array.map(item => Number.parseInt(item));
  }

  function getDefaultAmounts(tokens) {
    const defaultTokens = [100, 1000, 5000];

    if (tokens.length === 0) {
      return [];
    }

    return tokens.map((token) => defaultTokens[token]);
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
    <Home on:setupContainer={handleSetupContainer} />
  {/if}
</main>
