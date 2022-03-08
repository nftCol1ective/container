<script>
  import { onMount } from "svelte";

  import { containers, account, containerAddress, entitiesContract, entitiesAddress } from "../lib/store.js";

  let currentIndex = 0;


  onMount(() => {
    const split = document.location.hash.split('/');

    if (split.length === 2) {
      currentIndex = split[1];
    }
  })

  async function transferGold() {
    console.log('transfer gold');

    const tx = await $entitiesContract.safeTransferFrom($entitiesAddress, $containerAddress, currentIndex, 1, []);
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
    <button on:click={transferGold}>Load Gold</button>
    <button>Load Silver</button>
    <button>Load Elixir</button>
  </section>

  {@html $containers[currentIndex]?.image}
{/if}
