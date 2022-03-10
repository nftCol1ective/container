<script>
  import { onMount } from "svelte";

  import { account, containers, containerContract, entitiesContract, provider } from "../lib/store.js";

  import { ContractFactory } from 'ethers';
  import { decodeTokenUri } from "../lib/utils.js";

  export let entitiesArtifact;


  let currentIndex = 0;


  onMount(() => {
    const split = document.location.hash.split('/');

    if (split.length === 2) {
      currentIndex = Number.parseInt(split[1]);
    }
  })

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

  async function requestAvailableEntities() {
    const encoded = await $entitiesContract.getAvailableEntityMetadata();
    return encoded.map((item => {
      decodeTokenUri(item);
    }))
  }

  async function transferEntity(id) {
    console.log(`transfer ${id}`);

    const tx = await $entitiesContract.safeTransferFrom($provider.getSigner().getAddress(),
      $containerContract.address, id, 1, [currentIndex]);
    await tx.wait();
  }
</script>


<style>
  #action {
    display: flex;
    gap: 5px;
  }
</style>


{#if ($account)}
  <section id='action'>
    {#if (!$entitiesContract)}
      <button on:click={handleCreateItemset}>Create game item set</button>
    {:else}
      <button on:click={() => transferEntity(0)}>Transfer Gold</button>
      <button>Load Silver</button>
      <button>Load Elixir</button>
    {/if}
  </section>

  {@html $containers[currentIndex]?.image}
{/if}
